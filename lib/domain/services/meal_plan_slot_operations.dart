import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';

class SlotMoveOperation {
  final String entryId;
  final DateTime newDate;
  final MealType newMealType;

  const SlotMoveOperation({
    required this.entryId,
    required this.newDate,
    required this.newMealType,
  });
}

List<SlotMoveOperation> moveEntriesToSlot({
  required List<MealPlanEntry> entries,
  required DateTime targetDate,
  required MealType targetMealType,
}) {
  if (entries.isEmpty) return const [];
  final first = entries.first;
  if (_sameSlot(first.date, first.mealType, targetDate, targetMealType)) {
    return const [];
  }
  return [
    for (final e in entries)
      SlotMoveOperation(
        entryId: e.id,
        newDate: targetDate,
        newMealType: targetMealType,
      ),
  ];
}

List<SlotMoveOperation> swapSlotContents({
  required List<MealPlanEntry> sourceEntries,
  required List<MealPlanEntry> targetEntries,
  required DateTime sourceDate,
  required MealType sourceMealType,
  required DateTime targetDate,
  required MealType targetMealType,
}) {
  if (_sameSlot(sourceDate, sourceMealType, targetDate, targetMealType)) {
    return const [];
  }
  return [
    for (final e in sourceEntries)
      SlotMoveOperation(
        entryId: e.id,
        newDate: targetDate,
        newMealType: targetMealType,
      ),
    for (final e in targetEntries)
      SlotMoveOperation(
        entryId: e.id,
        newDate: sourceDate,
        newMealType: sourceMealType,
      ),
  ];
}

bool _sameSlot(DateTime a, MealType am, DateTime b, MealType bm) {
  return am == bm && a.year == b.year && a.month == b.month && a.day == b.day;
}
