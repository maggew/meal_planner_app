import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/auth.dart';
import 'package:meal_planner/services/database.dart';

@RoutePage()
class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreen();
}

class _AuthScreen extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final uid = Auth().getCurrentUser();

    if (uid.isEmpty) {
      AutoRouter.of(context).replace(const LoginRoute());
      return;
    }

    final groupId = await Database().getCurrentGroupID();

    if (groupId.isEmpty) {
      AutoRouter.of(context).replace(const GroupsRoute());
    } else {
      AutoRouter.of(context).replace(const CookbookRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldBody: Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );
  }
}
