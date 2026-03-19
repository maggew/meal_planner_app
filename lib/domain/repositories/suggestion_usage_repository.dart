import 'package:meal_planner/domain/entities/suggestion_usage.dart';

abstract class SuggestionUsageRepository {
  Future<SuggestionUsage> getCurrentWeekUsage(String groupId);
  Future<void> incrementUsage(String groupId);
}
