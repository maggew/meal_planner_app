import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_body.dart';
import 'package:meal_planner/services/providers/sync/sync_providers.dart';

@RoutePage()
class DetailedWeekplanPage extends ConsumerStatefulWidget {
  const DetailedWeekplanPage({super.key});

  @override
  ConsumerState<DetailedWeekplanPage> createState() =>
      _DetailedWeekplanPageState();
}

class _DetailedWeekplanPageState extends ConsumerState<DetailedWeekplanPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncCoordinatorProvider).enableMealPlanPolling(DateTime.now());
    });
  }

  @override
  void dispose() {
    ref.read(syncCoordinatorProvider).disableMealPlanPolling();
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
