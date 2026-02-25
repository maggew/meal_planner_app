import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/presentation/detailes_weekplan/widgets/weekplan_recipe_picker.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';

class WeekplanMealCard extends ConsumerWidget {
  final MealType mealType;
  final MealPlanEntry? entry;
  final DateTime selectedDay;

  const WeekplanMealCard({
    super.key,
    required this.mealType,
    required this.entry,
    required this.selectedDay,
  });

  static const _icons = {
    MealType.breakfast: Icons.wb_sunny_outlined,
    MealType.lunch: Icons.lunch_dining,
    MealType.dinner: Icons.nights_stay_outlined,
  };

  void _onAddTapped(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WeekplanRecipePicker(
        onSelected: (recipeId) {
          ref.read(mealPlanActionsProvider).addEntry(
                date: selectedDay,
                mealType: mealType,
                recipeId: recipeId,
              );
        },
      ),
    );
  }

  void _onRemoveTapped(WidgetRef ref) {
    ref.read(mealPlanActionsProvider).removeEntry(entry!.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve recipe name if an entry exists
    final recipeNameAsync = entry != null
        ? ref.watch(recipeNameProvider(entry!.recipeId))
        : const AsyncData<String?>(null);

    final recipeName = recipeNameAsync.value;

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
                _MealTypeIcon(
                  icon: _icons[mealType]!,
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType.displayName,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        recipeName ?? 'Mahlzeit hinzufügen',
                        style: textTheme.bodyMedium?.copyWith(
                          color: recipeName != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.45),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (entry != null)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    onPressed: () => _onRemoveTapped(ref),
                  )
                else
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    onPressed: () => _onAddTapped(context, ref),
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
