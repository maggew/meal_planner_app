import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';

class WeekplanMealCard extends StatelessWidget {
  final String mealType;
  final IconData icon;

  const WeekplanMealCard({
    super.key,
    required this.mealType,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surface.withValues(alpha: 0.3)
                  : colorScheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                _MealTypeIcon(icon: icon, colorScheme: colorScheme),
                const SizedBox(width: 14),
                _MealTypeLabel(
                  mealType: mealType,
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                ),
                Icon(
                  Icons.add_circle_outline,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MealTypeIcon extends StatelessWidget {
  final IconData icon;
  final ColorScheme colorScheme;

  const _MealTypeIcon({required this.icon, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: colorScheme.primary),
    );
  }
}

class _MealTypeLabel extends StatelessWidget {
  final String mealType;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _MealTypeLabel({
    required this.mealType,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mealType,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Mahlzeit hinzufügen',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
