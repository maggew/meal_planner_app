import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/meal_plan/meal_plan_realtime_service.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

final mealPlanRealtimeServiceProvider =
    Provider<MealPlanRealtimeService>((ref) {
  final session = ref.watch(sessionProvider);
  return MealPlanRealtimeService(
    supabase: ref.watch(supabaseProvider),
    dao: ref.watch(mealPlanDaoProvider),
    groupId: session.groupId ?? '',
  );
});
