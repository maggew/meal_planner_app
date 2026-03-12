import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/group_onboarding/widgets/group_onboarding_body.dart';

@RoutePage()
class GroupOnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AppBackground(
      scaffoldAppBar: CommonAppbar(
        title: 'Willkommen',
        automaticallyImplyLeading: false,
      ),
      scaffoldBody: GroupOnboardingBody(),
    );
  }
}
