import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';

abstract class MealPlanRepository {
  Stream<List<MealPlanEntry>> watchEntriesForDate(DateTime date);

  Future<void> addEntry({
    required DateTime date,
    required MealType mealType,
    required String recipeId,
  });

  Future<void> removeEntry(String localId);

  Future<void> setCook(String localId, String? cookId);
}
