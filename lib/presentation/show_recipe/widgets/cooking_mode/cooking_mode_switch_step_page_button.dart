import 'package:flutter/material.dart';

class CookingModeSwitchStepPageButton extends StatelessWidget {
  const CookingModeSwitchStepPageButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconAfter = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool iconAfter;

  static final ButtonStyle _style = ElevatedButton.styleFrom(
    backgroundColor: Colors.amber.shade400,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    minimumSize: const Size(100, 60),
  );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: _style,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconAfter ? Text(label) : Icon(icon),
          const SizedBox(width: 8),
          iconAfter ? Icon(icon) : Text(label),
        ],
      ),
    );
  }
}
