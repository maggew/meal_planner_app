import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/registration/widgets/registration_body.dart';

@RoutePage()
class RegistrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(title: "Registrierung"),
      scaffoldBody: RegistrationBody(),
    );
  }
}
