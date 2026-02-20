import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';

class CookingModeSwitchStepPageButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool iconAfter;
  final bool isPrimary;

  const CookingModeSwitchStepPageButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconAfter = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final style = isPrimary
        ? ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
            minimumSize: const Size(100, 60),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
            side:
                BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
            minimumSize: const Size(100, 60),
          );

    final Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        iconAfter ? Text(label) : Icon(icon),
        const SizedBox(width: 8),
        iconAfter ? Icon(icon) : Text(label),
      ],
    );

    return isPrimary
        ? ElevatedButton(style: style, onPressed: onPressed, child: child)
        : OutlinedButton(style: style, onPressed: onPressed, child: child);
  }
}
