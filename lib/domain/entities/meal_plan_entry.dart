import 'package:meal_planner/domain/enums/meal_type.dart';

class MealPlanEntry {
  final String id; // localId
  final String? remoteId;
  final String groupId;
  final String? recipeId;
  final String? customName;
  final DateTime date;
  final MealType mealType;
  final String? cookId;

  const MealPlanEntry({
    required this.id,
    this.remoteId,
    required this.groupId,
    this.recipeId,
    this.customName,
    required this.date,
    required this.mealType,
    this.cookId,
  });
}
