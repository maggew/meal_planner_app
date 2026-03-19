import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/suggestion_usage.dart';
import 'package:meal_planner/domain/repositories/suggestion_usage_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSuggestionUsageRepository implements SuggestionUsageRepository {
  final SupabaseClient _supabase;

  SupabaseSuggestionUsageRepository({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<SuggestionUsage> getCurrentWeekUsage(String groupId) async {
    final now = DateTime.now();
    final (weekYear, weekNumber) = _isoWeek(now);

    final response = await _supabase
        .from(SupabaseConstants.suggestionUsageTable)
        .select()
        .eq(SupabaseConstants.suggestionUsageGroupId, groupId)
        .eq(SupabaseConstants.suggestionUsageWeekYear, weekYear)
        .eq(SupabaseConstants.suggestionUsageWeekNumber, weekNumber)
        .maybeSingle();

    if (response == null) {
      return SuggestionUsage(
        groupId: groupId,
        weekYear: weekYear,
        weekNumber: weekNumber,
        usageCount: 0,
      );
    }

    return SuggestionUsage(
      groupId: groupId,
      weekYear: response[SupabaseConstants.suggestionUsageWeekYear] as int,
      weekNumber:
          response[SupabaseConstants.suggestionUsageWeekNumber] as int,
      usageCount:
          response[SupabaseConstants.suggestionUsageCount] as int? ?? 0,
    );
  }

  @override
  Future<void> incrementUsage(String groupId) async {
    final now = DateTime.now();
    final (weekYear, weekNumber) = _isoWeek(now);

    // Try to get existing row
    final existing = await _supabase
        .from(SupabaseConstants.suggestionUsageTable)
        .select()
        .eq(SupabaseConstants.suggestionUsageGroupId, groupId)
        .eq(SupabaseConstants.suggestionUsageWeekYear, weekYear)
        .eq(SupabaseConstants.suggestionUsageWeekNumber, weekNumber)
        .maybeSingle();

    if (existing != null) {
      final currentCount =
          existing[SupabaseConstants.suggestionUsageCount] as int? ?? 0;
      await _supabase
          .from(SupabaseConstants.suggestionUsageTable)
          .update({
            SupabaseConstants.suggestionUsageCount: currentCount + 1,
          })
          .eq(SupabaseConstants.suggestionUsageId,
              existing[SupabaseConstants.suggestionUsageId])
          ;
    } else {
      await _supabase.from(SupabaseConstants.suggestionUsageTable).insert({
        SupabaseConstants.suggestionUsageGroupId: groupId,
        SupabaseConstants.suggestionUsageWeekYear: weekYear,
        SupabaseConstants.suggestionUsageWeekNumber: weekNumber,
        SupabaseConstants.suggestionUsageCount: 1,
      });
    }
  }

  /// Returns (year, weekNumber) according to ISO 8601.
  static (int, int) _isoWeek(DateTime date) {
    // ISO weeks start on Monday
    final thursday = date.add(Duration(days: DateTime.thursday - date.weekday));
    final jan1 = DateTime(thursday.year, 1, 1);
    final weekNumber =
        ((thursday.difference(jan1).inDays) / 7).floor() + 1;
    return (thursday.year, weekNumber);
  }
}
