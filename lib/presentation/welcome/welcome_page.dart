import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/presentation/welcome/widgets/welcome_body.dart';

@RoutePage()
class WelcomePage extends StatefulWidget {
  @override
  State<WelcomePage> createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) {
        return;
      }
      context.router.replace(const CookbookRoute());
    });
  }

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldBody: WelcomeBody(),
    );
  }
}
