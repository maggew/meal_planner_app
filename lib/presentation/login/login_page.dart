import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/login/widgets/login_body.dart';

@RoutePage()
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AppBackground(
      scaffoldAppBar: AppBar(
        leading: Text(""),
        title: Text("Login", style: textTheme.displaySmall),
        centerTitle: true,
      ),
      scaffoldBody: LoginBody(),
    );
  }
}
