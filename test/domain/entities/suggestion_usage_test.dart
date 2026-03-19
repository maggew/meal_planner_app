import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/suggestion_usage.dart';

void main() {
  group('SuggestionUsage', () {
    test('limitReached gibt true bei usageCount >= 3', () {
      final usage = SuggestionUsage(
        groupId: 'g1',
        weekYear: 2026,
        weekNumber: 12,
        usageCount: 3,
      );
      expect(usage.limitReached, true);
    });

    test('limitReached gibt true bei usageCount > 3', () {
      final usage = SuggestionUsage(
        groupId: 'g1',
        weekYear: 2026,
        weekNumber: 12,
        usageCount: 5,
      );
      expect(usage.limitReached, true);
    });

    test('limitReached gibt false bei usageCount < 3', () {
      final usage = SuggestionUsage(
        groupId: 'g1',
        weekYear: 2026,
        weekNumber: 12,
        usageCount: 2,
      );
      expect(usage.limitReached, false);
    });

    test('limitReached gibt false bei usageCount = 0', () {
      final usage = SuggestionUsage(
        groupId: 'g1',
        weekYear: 2026,
        weekNumber: 12,
        usageCount: 0,
      );
      expect(usage.limitReached, false);
    });

    test('freeWeeklyLimit ist 3', () {
      expect(SuggestionUsage.freeWeeklyLimit, 3);
    });

    test('freeResultLimit ist 5', () {
      expect(SuggestionUsage.freeResultLimit, 5);
    });

    test('default usageCount ist 0', () {
      final usage = SuggestionUsage(
        groupId: 'g1',
        weekYear: 2026,
        weekNumber: 12,
      );
      expect(usage.usageCount, 0);
      expect(usage.limitReached, false);
    });

    test('copyWith aktualisiert usageCount korrekt', () {
      final usage = SuggestionUsage(
        groupId: 'g1',
        weekYear: 2026,
        weekNumber: 12,
        usageCount: 1,
      );
      final updated = usage.copyWith(usageCount: 3);
      expect(updated.usageCount, 3);
      expect(updated.limitReached, true);
      expect(updated.groupId, 'g1');
    });
  });
}
