import 'package:meal_planner/domain/entities/recipe.dart';

enum MatchQuality { perfect, partial, other }

class RecipeSuggestion {
  final Recipe recipe;
  final double totalScore;
  final double ingredientScore;
  final double rotationScore;
  final double carbVarietyScore;
  final int matchedIngredientCount;
  final int totalInputIngredients;
  final MatchQuality matchQuality;

  const RecipeSuggestion({
    required this.recipe,
    required this.totalScore,
    required this.ingredientScore,
    required this.rotationScore,
    required this.carbVarietyScore,
    required this.matchedIngredientCount,
    required this.totalInputIngredients,
    required this.matchQuality,
  });
}
