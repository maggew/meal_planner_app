import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_body.dart';
import 'package:meal_planner/services/meal_plan/meal_plan_sync_service.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_sync_provider.dart';

@RoutePage()
class DetailedWeekplanPage extends ConsumerStatefulWidget {
  const DetailedWeekplanPage({super.key});

  @override
  ConsumerState<DetailedWeekplanPage> createState() =>
      _DetailedWeekplanPageState();
}

class _DetailedWeekplanPageState extends ConsumerState<DetailedWeekplanPage> {
  MealPlanSyncService? _syncService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      _syncService = ref.read(mealPlanSyncServiceProvider);
      _syncService!.start(now.year, now.month);
    });
  }

  @override
  void dispose() {
    _syncService?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(title: 'Wochenplan', automaticallyImplyLeading: false),
      scaffoldBody: const WeekplanBody(),
    );
  }
}
