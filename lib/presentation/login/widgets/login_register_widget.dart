import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

class LoginRegisterWidget extends StatelessWidget {
  const LoginRegisterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Du hast noch keinen Account?",
        ),
        TextButton(
          child: Text(
            "Registrieren",
            style: TextStyle(
                color: Colors.green[100],
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline),
          ),
          onPressed: () {
            context.router.push(const RegistrationRoute());
          },
        ),
      ],
    );
  }
}
