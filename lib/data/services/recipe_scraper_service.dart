import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:meal_planner/data/model/scraped_recipe_data.dart';
import 'package:meal_planner/services/recipe_extractor.dart';

class RecipeScrapingException implements Exception {
  final String message;
  RecipeScrapingException(this.message);

  @override
  String toString() => message;
}

class RecipeScraperService {
  final Dio _dio;
  RecipeScraperService(this._dio);

  Future<ScrapedRecipeData> scrape(String url) async {
    late final String html;
    try {
      final response = await _dio.get<String>(
        url,
        options: Options(
          headers: {'User-Agent': 'Mozilla/5.0 (compatible; RecipeBot/1.0)'},
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
      final numbered = steps
          .asMap()
          .entries
          .map((e) => '${e.key + 1}. ${e.value}')
          .toList();
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
          headers: {'User-Agent': 'Mozilla/5.0 (compatible; RecipeBot/1.0)'},
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
