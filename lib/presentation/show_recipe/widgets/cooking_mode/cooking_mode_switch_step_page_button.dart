import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';

class CookingModeSwitchStepPageButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool iconAfter;

  const CookingModeSwitchStepPageButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconAfter = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        minimumSize: const Size(100, 60),
      ),
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
