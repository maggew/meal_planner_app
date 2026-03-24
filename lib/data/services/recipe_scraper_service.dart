import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
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

    final List<String> rawIngredients = [];
    final ingredientsRaw = recipeJson['recipeIngredient'];
    if (ingredientsRaw is List) {
      for (final item in ingredientsRaw) {
        if (item is String && item.trim().isNotEmpty) {
          rawIngredients.add(item.trim());
        }
      }
    }

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
