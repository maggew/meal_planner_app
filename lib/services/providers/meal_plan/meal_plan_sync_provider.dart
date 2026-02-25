import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/meal_plan/meal_plan_sync_service.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

final mealPlanSyncServiceProvider = Provider<MealPlanSyncService>((ref) {
  final session = ref.watch(sessionProvider);
  return MealPlanSyncService(
    dao: ref.watch(mealPlanDaoProvider),
    supabase: ref.watch(supabaseProvider),
    groupId: session.groupId ?? '',
  );
});
