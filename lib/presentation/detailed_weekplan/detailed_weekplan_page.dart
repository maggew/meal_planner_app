import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/data/sync/sync_feature.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/common/sync_polling_mixin.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_body.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

@RoutePage()
class DetailedWeekplanPage extends ConsumerStatefulWidget {
  const DetailedWeekplanPage({super.key});

  @override
  ConsumerState<DetailedWeekplanPage> createState() =>
      _DetailedWeekplanPageState();
}

class _DetailedWeekplanPageState extends ConsumerState<DetailedWeekplanPage>
    with SyncPollingMixin {
  final _visibleMonth = ValueNotifier<DateTime>(DateTime.now());

  @override
  SyncFeature get syncFeature => MealPlanSync(monthNotifier: _visibleMonth);

  @override
  String get syncRouteName => DetailedWeekplanRoute.name;

  @override
  void dispose() {
    _visibleMonth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar:
          CommonAppbar(title: 'Wochenplan', automaticallyImplyLeading: false),
      scaffoldBody: WeekplanBody(visibleMonth: _visibleMonth),
    );
  }
}
