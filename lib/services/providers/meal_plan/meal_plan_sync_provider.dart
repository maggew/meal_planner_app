import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/data/repositories/offline_first_meal_plan_repository.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

final mealPlanSyncServiceProvider =
    Provider<OfflineFirstMealPlanRepository>((ref) {
  return ref.watch(offlineFirstMealPlanProvider);
});
