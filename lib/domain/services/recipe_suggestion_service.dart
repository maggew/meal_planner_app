import 'package:meal_planner/core/utils/german_text_normalizer.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/recipe_suggestion.dart';

class RecipeSuggestionService {
  static const _weightIngredient = 0.50;
  static const _weightRotation = 0.30;
  static const _weightCarbVariety = 0.20;

  /// [recipes]          — all recipes from local cache
  /// [inputIngredients] — user-entered ingredient names
  /// [lastCookedMap]    — recipeId → days since last cooked (absent = never cooked)
  /// [recentCarbTags]   — carb tags from last 3 days (for variety scoring)
  static List<RecipeSuggestion> suggest({
    required List<Recipe> recipes,
    required List<String> inputIngredients,
    required Map<String, int> lastCookedMap,
    required List<String> recentCarbTags,
  }) {
    final suggestions = recipes
        .where((r) => r.id != null)
        .map((recipe) => _score(
              recipe: recipe,
              inputIngredients: inputIngredients,
              lastCookedDaysAgo: lastCookedMap[recipe.id!],
              recentCarbTags: recentCarbTags,
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
    required int? lastCookedDaysAgo,
    required List<String> recentCarbTags,
  }) {
    final matchedCount = _countMatches(recipe, inputIngredients);
    final ingredientScore = _calcIngredientScore(matchedCount, inputIngredients.length);
    final rotationScore = _calcRotationScore(lastCookedDaysAgo);
    final carbVarietyScore = _calcCarbVarietyScore(recipe, recentCarbTags);

    final totalScore = ingredientScore * _weightIngredient +
        rotationScore * _weightRotation +
        carbVarietyScore * _weightCarbVariety;

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

  static double _calcRotationScore(int? lastCookedDaysAgo) {
    if (lastCookedDaysAgo == null) return 1.0;
    return (lastCookedDaysAgo / 14.0).clamp(0.0, 1.0);
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
