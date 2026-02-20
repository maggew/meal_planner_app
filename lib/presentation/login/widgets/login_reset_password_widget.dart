import 'package:flutter/material.dart';

class LoginResetPasswordWidget extends StatelessWidget {
  const LoginResetPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 50,
      color: colorScheme.error,
      child: Center(child: Text("hier passwort zurücksetzten")),
    );
  }
}
