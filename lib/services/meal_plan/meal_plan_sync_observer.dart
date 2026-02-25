import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_sync_provider.dart';

class MealPlanSyncObserver extends WidgetsBindingObserver {
  final WidgetRef ref;
  MealPlanSyncObserver(this.ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      ref.read(mealPlanSyncServiceProvider).sync(now.year, now.month);
    }
  }
}
