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
  final int rotationWeight;
  final int carbVarietyWeight;

  const RecipeSuggestion({
    required this.recipe,
    required this.totalScore,
    required this.ingredientScore,
    required this.rotationScore,
    required this.carbVarietyScore,
    required this.matchedIngredientCount,
    required this.totalInputIngredients,
    required this.matchQuality,
    required this.rotationWeight,
    required this.carbVarietyWeight,
  });

  /// Effective weight factors (same calculation as in RecipeSuggestionService).
  double get _rw {
    final t = rotationWeight + carbVarietyWeight;
    return t > 0 ? rotationWeight / t * 0.5 : 0.0;
  }

  double get _cw {
    final t = rotationWeight + carbVarietyWeight;
    return t > 0 ? carbVarietyWeight / t * 0.5 : 0.0;
  }

  double get _iw => 1.0 - _rw - _cw;

  /// Weighted contribution of each criterion to the total score (0–1).
  double get ingredientContribution => ingredientScore * _iw;
  double get rotationContribution => rotationScore * _rw;
  double get carbVarietyContribution => carbVarietyScore * _cw;
}
