import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' show Element;
import 'package:html/parser.dart' as html_parser;
import 'package:meal_planner/data/model/scraped_recipe_data.dart';
import 'package:meal_planner/services/recipe_extractor.dart';

class RecipeScrapingException implements Exception {
  final String message;
  RecipeScrapingException(this.message);

  @override
  String toString() => message;
}

/// Intermediate result from the heuristic parser. Holds the raw image URL
/// (not yet downloaded) so the parser can stay synchronous and testable.
class HeuristicRecipeData {
  final String? name;
  final List<String> ingredients;
  final String? instructions;
  final int? servings;
  final String? imageUrl;

  const HeuristicRecipeData({
    this.name,
    required this.ingredients,
    this.instructions,
    this.servings,
    this.imageUrl,
  });
}

class RecipeScraperService {
  // A real-browser User-Agent + standard browser headers. Cloudflare and
  // other bot filters routinely reject obvious bot UAs (and even quietly
  // strip recipe content from the response), so we impersonate Chrome.
  static const String _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  static const Map<String, String> _browserHeaders = {
    'User-Agent': _userAgent,
    'Accept-Language': 'de-DE,de;q=0.9,en;q=0.8',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
  };

  final Dio _dio;
  RecipeScraperService(this._dio);

  Future<ScrapedRecipeData> scrape(String url) async {
    // Pinterest pages are JS-rendered social posts without recipe data;
    // there is nothing to scrape. Tell the user where to look instead.
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    if (host.contains('pinterest') || host == 'pin.it') {
      throw RecipeScrapingException(
        'Pinterest-Links werden nicht unterstützt. '
        'Bitte öffne den Pin und verwende den Link zum Originalrezept.',
      );
    }

    late final String html;
    try {
      final response = await _dio.get<String>(
        url,
        options: Options(
          headers: _browserHeaders,
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      html = response.data ?? '';
    } catch (e) {
      throw RecipeScrapingException('Seite konnte nicht geladen werden');
    }

    final scriptRegex = RegExp(
      r'''<script[^>]+type=["']application/ld\+json["'][^>]*>([\s\S]*?)</script>''',
      caseSensitive: false,
    );

    Map<String, dynamic>? recipeJson;
    for (final match in scriptRegex.allMatches(html)) {
      final jsonStr = match.group(1)?.trim();
      if (jsonStr == null || jsonStr.isEmpty) continue;
      try {
        final decoded = jsonDecode(jsonStr);
        recipeJson = _findRecipe(decoded);
        if (recipeJson != null) break;
      } catch (_) {
        continue;
      }
    }

    if (recipeJson == null) {
      // No JSON-LD Recipe — try the heuristic prose parser as a last resort.
      final heuristic = _tryExtractHeuristicRecipe(html);
      if (heuristic != null) {
        String? localImagePath;
        if (heuristic.imageUrl != null) {
          localImagePath = await _downloadImage(heuristic.imageUrl!);
        }
        return ScrapedRecipeData(
          name: heuristic.name,
          rawIngredients: heuristic.ingredients,
          instructions: heuristic.instructions,
          servings: heuristic.servings,
          localImagePath: localImagePath,
        );
      }
      throw RecipeScrapingException('Diese Seite wird nicht unterstützt');
    }

    final name = recipeJson['name'] as String?;

    // Try structured HTML extraction first (preserves ingredient sections),
    // fall back to flat JSON-LD list.
    final rawIngredients = _tryExtractWprmIngredients(html) ??
        _tryExtractTastyRecipesIngredients(html) ??
        _tryExtractIngredientBlocks(html) ??
        _extractJsonLdIngredients(recipeJson);

    final instructions = _extractInstructions(recipeJson['recipeInstructions']);
    final servings = _extractServings(recipeJson['recipeYield']);
    final imageUrl = _extractImageUrl(recipeJson['image']);

    String? localImagePath;
    if (imageUrl != null) {
      localImagePath = await _downloadImage(imageUrl);
    }

    return ScrapedRecipeData(
      name: name,
      rawIngredients: rawIngredients,
      instructions: instructions,
      servings: servings,
      localImagePath: localImagePath,
    );
  }

  List<String> _extractJsonLdIngredients(Map<String, dynamic> recipeJson) {
    final List<String> result = [];
    final raw = recipeJson['recipeIngredient'];
    if (raw is List) {
      for (final item in raw) {
        if (item is String && item.trim().isNotEmpty) {
          result.add(item.trim());
        }
      }
    }
    return result;
  }

  /// Heuristic recipe parser for unstructured WordPress prose pages
  /// (no JSON-LD Recipe, no recipe plugin). Walks the article scope looking
  /// for German/English "Zutaten"/"Zubereitung" headings and extracts the
  /// surrounding lists/paragraphs. Returns null if no recognizable
  /// ingredients section is found, or if extraction yields fewer than two
  /// ingredients (likely a false positive).
  @visibleForTesting
  HeuristicRecipeData? tryExtractHeuristicRecipe(String html) =>
      _tryExtractHeuristicRecipe(html);

  static final RegExp _ingredientsHeadingPattern =
      RegExp(r'^\s*(zutaten|ingredients)\b', caseSensitive: false);
  static final RegExp _instructionsHeadingPattern = RegExp(
    r'^\s*(zubereitung|anleitung|instructions|directions|method)\b',
    caseSensitive: false,
  );

  HeuristicRecipeData? _tryExtractHeuristicRecipe(String html) {
    final document = html_parser.parse(html);

    // Scope the walk to the post body so sidebar/footer/related-posts
    // carousels cannot pollute the result. Fall back gracefully for
    // themes that don't use semantic HTML5 elements.
    final scope = document.querySelector('article') ??
        document.querySelector('main') ??
        document.body;
    if (scope == null) return null;

    // Document-order list of all headings and content blocks we care about.
    final nodes =
        scope.querySelectorAll('h1, h2, h3, h4, ul, ol, p');

    // Find the ingredients heading.
    int? ingredientsStart;
    String? ingredientsHeadingText;
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (_isHeading(node) &&
          _ingredientsHeadingPattern.hasMatch(node.text)) {
        ingredientsStart = i;
        ingredientsHeadingText = node.text;
        break;
      }
    }
    if (ingredientsStart == null) return null;

    // Walk forward collecting ul/ol items and bold-only <p> as section
    // headers, until we hit the next heading of any level.
    final List<String> ingredients = [];
    for (int i = ingredientsStart + 1; i < nodes.length; i++) {
      final node = nodes[i];
      if (_isHeading(node)) break;
      final tag = node.localName;
      if (tag == 'ul' || tag == 'ol') {
        for (final li in node.querySelectorAll('li')) {
          final text = li.text.trim();
          if (text.isNotEmpty) ingredients.add(text);
        }
      } else if (tag == 'p') {
        final headerText = _paragraphAsBoldHeader(node);
        if (headerText != null) {
          ingredients
              .add(headerText.endsWith(':') ? headerText : '$headerText:');
        }
        // Plain prose paragraphs between lists are ignored: they're tips,
        // ads, or commentary, not recipe data.
      }
    }

    if (ingredients.length < 2) return null;

    // Optional: walk for instructions. If absent, we still return the
    // recipe — the user can fill in the steps manually in the editor.
    String? instructions;
    for (int i = ingredientsStart + 1; i < nodes.length; i++) {
      final node = nodes[i];
      if (!_isHeading(node)) continue;
      if (!_instructionsHeadingPattern.hasMatch(node.text)) continue;

      final List<String> steps = [];
      for (int j = i + 1; j < nodes.length; j++) {
        final stepNode = nodes[j];
        if (_isHeading(stepNode)) break;
        if (stepNode.localName != 'p') continue;
        // Skip pure-bold paragraphs (sub-headers within instructions).
        if (_paragraphAsBoldHeader(stepNode) != null) continue;
        final text = stepNode.text.trim();
        if (text.isNotEmpty) steps.add(text);
      }

      if (steps.isNotEmpty) {
        final numbered = steps
            .asMap()
            .entries
            .map((e) => '${e.key + 1}. ${e.value}')
            .toList();
        instructions = RecipeExtractor.assembleNumberedSteps(numbered);
      }
      break;
    }

    // Title from og:title (with site-name suffix stripped).
    final ogTitle = document
        .querySelector('meta[property="og:title"]')
        ?.attributes['content'];
    if (ogTitle == null || ogTitle.trim().isEmpty) return null;
    final siteName = document
        .querySelector('meta[property="og:site_name"]')
        ?.attributes['content'];
    final name = _stripSiteSuffix(ogTitle, siteName);

    // Image from og:image (URL only — caller downloads it).
    final imageUrl = document
        .querySelector('meta[property="og:image"]')
        ?.attributes['content'];

    // Servings from the ingredients heading text.
    final servings = _extractServingsFromHeading(ingredientsHeadingText!);

    return HeuristicRecipeData(
      name: name,
      ingredients: ingredients,
      instructions: instructions,
      servings: servings,
      imageUrl: imageUrl,
    );
  }

  bool _isHeading(Element node) {
    final tag = node.localName;
    return tag == 'h1' || tag == 'h2' || tag == 'h3' || tag == 'h4';
  }

  /// Returns the trimmed text of [p] iff its entire visible text is wrapped
  /// in <strong>/<b> tags (i.e. it's a styled section header). Returns null
  /// for normal prose paragraphs and for paragraphs that mix bold + plain
  /// text (e.g. "Tipp: <strong>...</strong>").
  String? _paragraphAsBoldHeader(Element p) {
    final fullText = p.text.trim();
    if (fullText.isEmpty) return null;
    final boldText = p
        .querySelectorAll('strong, b')
        .map((e) => e.text)
        .join('')
        .trim();
    if (boldText.isEmpty) return null;
    if (boldText != fullText) return null;
    return boldText;
  }

  String _stripSiteSuffix(String title, String? siteName) {
    final trimmedTitle = title.trim();
    if (siteName == null || siteName.trim().isEmpty) return trimmedTitle;
    final trimmedSite = siteName.trim();
    for (final sep in const [' - ', ' | ', ' – ', ' — ']) {
      final idx = trimmedTitle.lastIndexOf(sep);
      if (idx <= 0) continue;
      final suffix = trimmedTitle.substring(idx + sep.length).trim();
      if (suffix == trimmedSite) {
        return trimmedTitle.substring(0, idx).trim();
      }
    }
    return trimmedTitle;
  }

  int? _extractServingsFromHeading(String heading) {
    // "für 4 Portionen", "for 6 servings", "Serves 2", "(Serves 4)", etc.
    final m1 = RegExp(
      r'(\d+)\s*(?:portionen|personen|servings?|people)',
      caseSensitive: false,
    ).firstMatch(heading);
    if (m1 != null) return int.tryParse(m1.group(1)!);

    final m2 = RegExp(
      r'(?:für|for|serves)\s+(\d+)',
      caseSensitive: false,
    ).firstMatch(heading);
    if (m2 != null) return int.tryParse(m2.group(1)!);

    return null;
  }

  /// Extracts ingredients with section headers from WPRM HTML.
  /// Returns null if no WPRM structure is found.
  @visibleForTesting
  List<String>? tryExtractWprmIngredients(String html) =>
      _tryExtractWprmIngredients(html);

  List<String>? _tryExtractWprmIngredients(String html) {
    final document = html_parser.parse(html);
    final groups = document.querySelectorAll('.wprm-recipe-ingredient-group');
    if (groups.isEmpty) return null;

    final List<String> lines = [];
    for (final group in groups) {
      final headerEl = group.querySelector('.wprm-recipe-group-name');
      if (headerEl != null) {
        final headerText = headerEl.text.trim();
        if (headerText.isNotEmpty) {
          lines.add('$headerText:');
        }
      }

      final items = group.querySelectorAll('.wprm-recipe-ingredient');
      for (final item in items) {
        final amount =
            item.querySelector('.wprm-recipe-ingredient-amount')?.text.trim();
        final unit =
            item.querySelector('.wprm-recipe-ingredient-unit')?.text.trim();
        final name =
            item.querySelector('.wprm-recipe-ingredient-name')?.text.trim();
        final notes =
            item.querySelector('.wprm-recipe-ingredient-notes')?.text.trim();

        final parts = [amount, unit, name, notes]
            .where((p) => p != null && p.isNotEmpty)
            .join(' ');

        if (parts.isNotEmpty) {
          lines.add(parts);
        }
      }
    }

    return lines.isNotEmpty ? lines : null;
  }

  /// Extracts ingredients with section headers from Tasty Recipes HTML.
  /// Sections are marked by h3/h4 headings before each ingredient ul.
  /// Returns null if no Tasty Recipes structure is found.
  @visibleForTesting
  List<String>? tryExtractTastyRecipesIngredients(String html) =>
      _tryExtractTastyRecipesIngredients(html);

  List<String>? _tryExtractTastyRecipesIngredients(String html) {
    final document = html_parser.parse(html);
    final container = document.querySelector('.tasty-recipes-ingredients-body') ??
        document.querySelector('.tasty-recipes-ingredients');
    if (container == null) return null;

    final List<String> lines = [];
    for (final child in container.children) {
      final tag = child.localName;

      if (tag == 'h3' || tag == 'h4' || tag == 'h5') {
        final headerText = child.text.trim();
        if (headerText.isNotEmpty) {
          lines.add('$headerText:');
        }
      } else if (tag == 'ul' || tag == 'ol') {
        for (final li in child.querySelectorAll('li')) {
          final text = li.text.trim();
          if (text.isNotEmpty) {
            lines.add(text);
          }
        }
      }
    }

    return lines.isNotEmpty ? lines : null;
  }

  /// Extracts ingredients with section headers from embedded ingredientBlocks
  /// JSON (used by Drupal/Next.js recipe sites like einfachkochen.de).
  /// Returns null if no such structure is found.
  @visibleForTesting
  List<String>? tryExtractIngredientBlocks(String html) =>
      _tryExtractIngredientBlocks(html);

  List<String>? _tryExtractIngredientBlocks(String html) {
    // The key may appear unescaped ("ingredientBlocks":) or with escaped
    // quotes (\"ingredientBlocks\":) when embedded inside a JSON string.
    // Brackets are not escaped in either case.
    var marker = '"ingredientBlocks":';
    var idx = html.indexOf(marker);
    bool escaped = false;
    if (idx < 0) {
      marker = r'\"ingredientBlocks\":';
      idx = html.indexOf(marker);
      escaped = true;
    }
    if (idx < 0) return null;

    final arrayStart = html.indexOf('[', idx + marker.length);
    if (arrayStart < 0) return null;

    // Find matching closing bracket
    int depth = 0;
    int? arrayEnd;
    for (int i = arrayStart; i < html.length && i < arrayStart + 40000; i++) {
      if (html[i] == '[') depth++;
      if (html[i] == ']') depth--;
      if (depth == 0) {
        arrayEnd = i + 1;
        break;
      }
    }
    if (arrayEnd == null) return null;

    var raw = html.substring(arrayStart, arrayEnd);
    // Unescape quotes if the JSON was inside a JSON string
    if (escaped) {
      raw = raw.replaceAll(r'\"', '"');
    }

    List<dynamic> blocks;
    try {
      blocks = jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return null;
    }

    final List<String> lines = [];
    for (final block in blocks) {
      if (block is! Map<String, dynamic>) continue;

      final title = block['title'] as String?;
      if (title != null && title.isNotEmpty) {
        lines.add('$title:');
      }

      final ingredients = block['ingredients'];
      if (ingredients is! List) continue;

      for (final ing in ingredients) {
        if (ing is! Map<String, dynamic>) continue;

        final prefix = ing['prefix'] as String?;
        final quantity = ing['quantity'];
        final quantityEnd = ing['quantityEnd'];
        final unitMap = ing['unit'];
        final unit = unitMap is Map ? unitMap['name'] as String? : null;
        final ingMap = ing['ingredient'];
        final name = ingMap is Map ? ingMap['name'] as String? : null;
        final suffix = ing['suffix'] as String?;

        final parts = <String>[];
        if (quantity != null) {
          final qStr = quantity is int
              ? quantity.toString()
              : quantity is double
                  ? (quantity == quantity.truncateToDouble()
                      ? quantity.toInt().toString()
                      : quantity.toString())
                  : quantity.toString();
          if (quantityEnd != null) {
            parts.add('$qStr-$quantityEnd');
          } else {
            parts.add(qStr);
          }
        }
        if (unit != null && unit.isNotEmpty) parts.add(unit);
        if (prefix != null && prefix.isNotEmpty) {
          parts.add('$prefix ${name ?? ''}');
        } else if (name != null && name.isNotEmpty) {
          parts.add(name);
        }
        if (suffix != null && suffix.isNotEmpty) parts.add(suffix);

        final line = parts.join(' ').trim();
        if (line.isNotEmpty) lines.add(line);
      }
    }

    return lines.isNotEmpty ? lines : null;
  }

  Map<String, dynamic>? _findRecipe(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      if (_isRecipeType(decoded['@type'])) return decoded;
      final graph = decoded['@graph'];
      if (graph is List) {
        for (final item in graph) {
          if (item is Map<String, dynamic>) {
            final result = _findRecipe(item);
            if (result != null) return result;
          }
        }
      }
    } else if (decoded is List) {
      for (final item in decoded) {
        final result = _findRecipe(item);
        if (result != null) return result;
      }
    }
    return null;
  }

  bool _isRecipeType(dynamic type) {
    if (type is String) return type == 'Recipe';
    if (type is List) return type.contains('Recipe');
    return false;
  }

  String? _extractInstructions(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw.trim();
    if (raw is List) {
      final steps = <String>[];
      for (final item in raw) {
        if (item is String) {
          steps.add(item.trim());
        } else if (item is Map) {
          final text = item['text'] as String?;
          if (text != null && text.isNotEmpty) {
            steps.add(text.trim());
          } else {
            // HowToSection: steps are nested in itemListElement
            final nested = item['itemListElement'];
            if (nested is List) {
              for (final step in nested) {
                if (step is Map) {
                  final stepText = step['text'] as String?;
                  if (stepText != null && stepText.isNotEmpty) {
                    steps.add(stepText.trim());
                  }
                } else if (step is String && step.isNotEmpty) {
                  steps.add(step.trim());
                }
              }
            }
          }
        }
      }
      if (steps.isEmpty) return null;
      final alreadyNumbered = RegExp(r'^\s*1\s*[:\.\)\-]').hasMatch(steps.first);
      final List<String> numbered;
      if (alreadyNumbered) {
        numbered = steps;
      } else {
        numbered = steps
            .asMap()
            .entries
            .map((e) => '${e.key + 1}. ${e.value}')
            .toList();
      }
      return RecipeExtractor.assembleNumberedSteps(numbered);
    }
    if (raw is Map) return raw['text'] as String?;
    return null;
  }

  int? _extractServings(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    String str;
    if (raw is String) {
      str = raw;
    } else if (raw is List && raw.isNotEmpty) {
      str = raw.first.toString();
    } else {
      return null;
    }
    final match = RegExp(r'\d+').firstMatch(str);
    return match != null ? int.tryParse(match.group(0)!) : null;
  }

  String? _extractImageUrl(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw;
    if (raw is Map) return raw['url'] as String?;
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is String) return first;
      if (first is Map) return first['url'] as String?;
    }
    return null;
  }

  Future<String?> _downloadImage(String url) async {
    try {
      if (!url.startsWith('https://')) return null;
      final tempDir = Directory.systemTemp;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';
      await _dio.download(
        url,
        filePath,
        options: Options(
          headers: _browserHeaders,
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      return filePath;
    } catch (_) {
      return null;
    }
  }
}
