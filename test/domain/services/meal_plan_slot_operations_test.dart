import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/domain/services/meal_plan_slot_operations.dart';

MealPlanEntry _entry({
  required String id,
  required DateTime date,
  required MealType mealType,
  String? recipeId = 'r1',
  String? customName,
  List<String> cookIds = const [],
}) =>
    MealPlanEntry(
      id: id,
      groupId: 'g1',
      recipeId: recipeId,
      customName: customName,
      date: date,
      mealType: mealType,
      cookIds: cookIds,
    );

void main() {
  group('moveEntriesToSlot', () {
    test('produces one operation per entry with the target date and meal type',
        () {
      final source = DateTime(2026, 4, 15);
      final target = DateTime(2026, 4, 16);
      final entries = [
        _entry(id: 'a', date: source, mealType: MealType.dinner),
      ];

      final ops = moveEntriesToSlot(
        entries: entries,
        targetDate: target,
        targetMealType: MealType.lunch,
      );

      expect(ops, hasLength(1));
      expect(ops.first.entryId, 'a');
      expect(ops.first.newDate, target);
      expect(ops.first.newMealType, MealType.lunch);
    });

    test('returns empty list when target slot equals source slot', () {
      final date = DateTime(2026, 4, 15);
      final entries = [
        _entry(id: 'a', date: date, mealType: MealType.dinner),
        _entry(id: 'b', date: date, mealType: MealType.dinner),
      ];

      final ops = moveEntriesToSlot(
        entries: entries,
        targetDate: date,
        targetMealType: MealType.dinner,
      );

      expect(ops, isEmpty);
    });
  });

  group('swapSlotContents', () {
    test('source entries go to target slot, target entries go to source slot',
        () {
      final sourceDate = DateTime(2026, 4, 15);
      final targetDate = DateTime(2026, 4, 17);
      final sourceEntries = [
        _entry(id: 's1', date: sourceDate, mealType: MealType.dinner),
      ];
      final targetEntries = [
        _entry(id: 't1', date: targetDate, mealType: MealType.lunch),
      ];

      final ops = swapSlotContents(
        sourceEntries: sourceEntries,
        targetEntries: targetEntries,
        sourceDate: sourceDate,
        sourceMealType: MealType.dinner,
        targetDate: targetDate,
        targetMealType: MealType.lunch,
      );

      expect(ops, hasLength(2));
      final sourceOp = ops.firstWhere((o) => o.entryId == 's1');
      expect(sourceOp.newDate, targetDate);
      expect(sourceOp.newMealType, MealType.lunch);
      final targetOp = ops.firstWhere((o) => o.entryId == 't1');
      expect(targetOp.newDate, sourceDate);
      expect(targetOp.newMealType, MealType.dinner);
    });

    test('returns empty list when source slot equals target slot', () {
      final date = DateTime(2026, 4, 15);
      final sourceEntries = [
        _entry(id: 's1', date: date, mealType: MealType.lunch),
      ];
      final targetEntries = [
        _entry(id: 't1', date: date, mealType: MealType.lunch),
      ];

      final ops = swapSlotContents(
        sourceEntries: sourceEntries,
        targetEntries: targetEntries,
        sourceDate: date,
        sourceMealType: MealType.lunch,
        targetDate: date,
        targetMealType: MealType.lunch,
      );

      expect(ops, isEmpty);
    });

    test('handles multi-entry slots on both sides', () {
      final sourceDate = DateTime(2026, 4, 15);
      final targetDate = DateTime(2026, 4, 17);
      final sourceEntries = [
        _entry(id: 's1', date: sourceDate, mealType: MealType.dinner),
        _entry(id: 's2', date: sourceDate, mealType: MealType.dinner),
      ];
      final targetEntries = [
        _entry(id: 't1', date: targetDate, mealType: MealType.lunch),
        _entry(id: 't2', date: targetDate, mealType: MealType.lunch),
        _entry(id: 't3', date: targetDate, mealType: MealType.lunch),
      ];

      final ops = swapSlotContents(
        sourceEntries: sourceEntries,
        targetEntries: targetEntries,
        sourceDate: sourceDate,
        sourceMealType: MealType.dinner,
        targetDate: targetDate,
        targetMealType: MealType.lunch,
      );

      expect(ops, hasLength(5));
      for (final id in ['s1', 's2']) {
        final op = ops.firstWhere((o) => o.entryId == id);
        expect(op.newDate, targetDate);
        expect(op.newMealType, MealType.lunch);
      }
      for (final id in ['t1', 't2', 't3']) {
        final op = ops.firstWhere((o) => o.entryId == id);
        expect(op.newDate, sourceDate);
        expect(op.newMealType, MealType.dinner);
      }
    });
  });
}
