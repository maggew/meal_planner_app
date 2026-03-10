import 'package:meal_planner/core/utils/german_text_normalizer.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/recipe_suggestion.dart';

class RecipeSuggestionService {
  static const double _ingredientShare = 0.50;

  /// [recipes]            — all recipes from local cache
  /// [inputIngredients]   — user-entered ingredient names
  /// [lastCookedMap]      — recipeId → days to nearest occurrence (past or future)
  /// [recentCarbTags]     — carb tags from ±3 days around today
  /// [rotationWeight]     — 0–3: how strongly to weight rotation (0 = off)
  /// [carbVarietyWeight]  — 0–3: how strongly to weight carb variety (0 = off)
  static List<RecipeSuggestion> suggest({
    required List<Recipe> recipes,
    required List<String> inputIngredients,
    required Map<String, int> lastCookedMap,
    required List<String> recentCarbTags,
    int rotationWeight = 3,
    int carbVarietyWeight = 2,
  }) {
    final suggestions = recipes
        .where((r) => r.id != null)
        .map((recipe) => _score(
              recipe: recipe,
              inputIngredients: inputIngredients,
              lastCookedDaysAway: lastCookedMap[recipe.id!],
              recentCarbTags: recentCarbTags,
              rotationWeight: rotationWeight,
              carbVarietyWeight: carbVarietyWeight,
            ))
        .toList();

    suggestions.sort((a, b) {
      final qualityCompare =
          a.matchQuality.index.compareTo(b.matchQuality.index);
      if (qualityCompare != 0) return qualityCompare;
      return b.totalScore.compareTo(a.totalScore);
    });

    return suggestions;
  }

  static RecipeSuggestion _score({
    required Recipe recipe,
    required List<String> inputIngredients,
    required int? lastCookedDaysAway,
    required List<String> recentCarbTags,
    required int rotationWeight,
    required int carbVarietyWeight,
  }) {
    final matchedCount = _countMatches(recipe, inputIngredients);
    final ingredientScore =
        _calcIngredientScore(matchedCount, inputIngredients.length);
    final rotationScore = _calcRotationScore(lastCookedDaysAway);
    final carbVarietyScore =
        carbVarietyWeight > 0 ? _calcCarbVarietyScore(recipe, recentCarbTags) : 0.0;

    // Distribute the remaining 50% proportionally between rotation and carb variety.
    final rTotal = rotationWeight + carbVarietyWeight;
    final double rw =
        rTotal > 0 ? rotationWeight / rTotal * (1.0 - _ingredientShare) : 0.0;
    final double cw =
        rTotal > 0 ? carbVarietyWeight / rTotal * (1.0 - _ingredientShare) : 0.0;
    final double iw = 1.0 - rw - cw;

    final totalScore =
        ingredientScore * iw + rotationScore * rw + carbVarietyScore * cw;

    final matchQuality = _determineMatchQuality(
      matchedCount: matchedCount,
      totalInput: inputIngredients.length,
    );

    return RecipeSuggestion(
      recipe: recipe,
      totalScore: totalScore,
      ingredientScore: ingredientScore,
      rotationScore: rotationScore,
      carbVarietyScore: carbVarietyScore,
      matchedIngredientCount: matchedCount,
      totalInputIngredients: inputIngredients.length,
      matchQuality: matchQuality,
      rotationWeight: rotationWeight,
      carbVarietyWeight: carbVarietyWeight,
    );
  }

  static double _calcIngredientScore(int matchedCount, int totalInput) {
    if (totalInput == 0) return 0.5;
    return matchedCount / totalInput;
  }

  static int _countMatches(Recipe recipe, List<String> inputIngredients) {
    if (inputIngredients.isEmpty) return 0;
    final recipeIngredients = recipe.ingredientSections
        .expand((s) => s.ingredients)
        .map((i) => i.name)
        .toList();

    int matched = 0;
    for (final input in inputIngredients) {
      final hasMatch = recipeIngredients
          .any((ri) => GermanTextNormalizer.fuzzyMatch(input, ri));
      if (hasMatch) matched++;
    }
    return matched;
  }

  /// [lastCookedDaysAway] is the number of days to the nearest occurrence of
  /// this recipe (past or future). null means never planned/cooked.
  static double _calcRotationScore(int? lastCookedDaysAway) {
    if (lastCookedDaysAway == null) return 1.0;
    return (lastCookedDaysAway / 14.0).clamp(0.0, 1.0);
  }

  static double _calcCarbVarietyScore(
      Recipe recipe, List<String> recentCarbTags) {
    if (recentCarbTags.isEmpty) return 1.0;
    if (recipe.carbTags.isEmpty) return 1.0;

    final overlap =
        recipe.carbTags.where((tag) => recentCarbTags.contains(tag)).length;

    if (overlap == 0) return 1.0;
    return (1.0 - overlap / recipe.carbTags.length).clamp(0.0, 1.0);
  }

  static MatchQuality _determineMatchQuality({
    required int matchedCount,
    required int totalInput,
  }) {
    if (totalInput == 0) return MatchQuality.other;
    if (matchedCount == totalInput) return MatchQuality.perfect;
    if (matchedCount > 0) return MatchQuality.partial;
    return MatchQuality.other;
  }
}
