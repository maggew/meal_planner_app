import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_body.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/sync/sync_providers.dart';

@RoutePage()
class DetailedWeekplanPage extends ConsumerStatefulWidget {
  const DetailedWeekplanPage({super.key});

  @override
  ConsumerState<DetailedWeekplanPage> createState() =>
      _DetailedWeekplanPageState();
}

class _DetailedWeekplanPageState extends ConsumerState<DetailedWeekplanPage> {
  TabsRouter? _tabsRouter;
  bool _polling = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = AutoTabsRouter.of(context);
    if (_tabsRouter != router) {
      _tabsRouter?.removeListener(_onTabChange);
      _tabsRouter = router;
      _tabsRouter!.addListener(_onTabChange);
      _onTabChange();
    }
  }

  void _onTabChange() {
    final router = _tabsRouter;
    if (router == null) return;
    final isActive = router.current.name == DetailedWeekplanRoute.name;
    if (isActive && !_polling) {
      _polling = true;
      ref.read(syncCoordinatorProvider).enableMealPlanPolling(DateTime.now());
    } else if (!isActive && _polling) {
      _polling = false;
      ref.read(syncCoordinatorProvider).disableMealPlanPolling();
    }
  }

  @override
  void dispose() {
    _tabsRouter?.removeListener(_onTabChange);
    if (_polling) {
      ref.read(syncCoordinatorProvider).disableMealPlanPolling();
    }
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
