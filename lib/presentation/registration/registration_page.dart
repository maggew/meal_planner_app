import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/registration/widgets/registration_body.dart';

@RoutePage()
class RegistrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AppBackground(
      scaffoldAppBar: AppBar(
        leading: Text(""),
        title: Text("Registrierung", style: textTheme.displaySmall),
        centerTitle: true,
      ),
      scaffoldBody: RegistrationBody(),
    );
  }
}
