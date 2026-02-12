import 'package:flutter/material.dart';

class RegistrationButton extends StatelessWidget {
  final VoidCallback onPressed;
  const RegistrationButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(150, 40),
      ),
      onPressed: onPressed,
      child: Text("Registrieren"),
    );
  }
}
