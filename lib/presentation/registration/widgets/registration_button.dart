import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationButton extends ConsumerWidget {
  final VoidCallback onPressed;
  const RegistrationButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(150, 40),
      ),
      onPressed: onPressed,
      child: Text("Registrieren"),
    );
  }
}
