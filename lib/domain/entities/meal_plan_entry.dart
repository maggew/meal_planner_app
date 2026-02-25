import 'package:meal_planner/domain/enums/meal_type.dart';

class MealPlanEntry {
  final String id; // localId
  final String? remoteId;
  final String groupId;
  final String recipeId;
  final DateTime date;
  final MealType mealType;

  const MealPlanEntry({
    required this.id,
    this.remoteId,
    required this.groupId,
    required this.recipeId,
    required this.date,
    required this.mealType,
  });
}
