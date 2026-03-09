import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_body.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/meal_plan/meal_plan_realtime_service.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_realtime_provider.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_sync_provider.dart';

@RoutePage()
class DetailedWeekplanPage extends ConsumerStatefulWidget {
  const DetailedWeekplanPage({super.key});

  @override
  ConsumerState<DetailedWeekplanPage> createState() =>
      _DetailedWeekplanPageState();
}

class _DetailedWeekplanPageState extends ConsumerState<DetailedWeekplanPage> {
  MealPlanRealtimeService? _realtimeService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      ref.read(mealPlanSyncServiceProvider).sync(now.year, now.month);
      _realtimeService = ref.read(mealPlanRealtimeServiceProvider);
      _realtimeService!.subscribe();
    });
  }

  @override
  void dispose() {
    _realtimeService?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(title: 'Wochenplan', leading: SizedBox.shrink()),
      scaffoldBody: const WeekplanBody(),
      scaffoldFloatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.router.push(const RecipeSuggestionRoute()),
        tooltip: 'Vorschläge',
        child: const Icon(Icons.auto_awesome),
      ),
    );
  }
}
