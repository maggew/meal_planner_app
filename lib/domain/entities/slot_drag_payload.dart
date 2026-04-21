import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';

/// Data that travels with a LongPressDraggable when the user drags a meal
/// slot on the weekplan. Slot-atomic: every entry of the source meal-type
/// on [date] moves together.
class SlotDragPayload {
  final DateTime date;
  final MealType mealType;
  final List<MealPlanEntry> entries;

  const SlotDragPayload({
    required this.date,
    required this.mealType,
    required this.entries,
  });
}
