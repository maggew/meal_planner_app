import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/detailes_weekplan/widgets/weekplan_body.dart';

@RoutePage()
class DetailedWeekplanPage extends StatelessWidget {
  const DetailedWeekplanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(title: 'Wochenplan'),
      scaffoldBody: const WeekplanBody(),
    );
  }
}
