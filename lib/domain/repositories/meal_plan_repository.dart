import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';

abstract class MealPlanRepository {
  Stream<List<MealPlanEntry>> watchEntriesForDate(DateTime date);

  Future<void> addEntry({
    required DateTime date,
    required MealType mealType,
    String? recipeId,
    String? customName,
    List<String> cookIds = const [],
  });

  Future<void> updateEntry(
    String localId, {
    String? recipeId,
    String? customName,
    List<String> cookIds = const [],
  });

  Future<void> removeEntry(String localId);

  Future<void> setCookIds(String localId, List<String> cookIds);

  /// Relocates an entry to a new (date, mealType) slot. Returns `true` when
  /// the entry was moved, `false` when no entry with [localId] exists —
  /// callers can surface a conflict hint in that case.
  Future<bool> moveEntry(
    String localId, {
    required DateTime date,
    required MealType mealType,
  });
}
