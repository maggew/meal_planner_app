import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_recipe_picker.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
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

  void _openAddPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WeekplanRecipePicker(
        onSelected: (recipeId, customName, cookId) {
          ref.read(mealPlanActionsProvider).addEntry(
                date: selectedDay,
                mealType: mealType,
                recipeId: recipeId,
                customName: customName,
                cookId: cookId,
              );
        },
      ),
    );
  }

  void _openEditPicker(
      BuildContext context, WidgetRef ref, String? displayName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WeekplanRecipePicker(
        initialLabel: displayName,
        initialRecipeId: entry!.recipeId,
        initialCustomName: entry!.customName,
        initialCookId: entry!.cookId,
        onSelected: (recipeId, customName, cookId) {
          ref.read(mealPlanActionsProvider).updateEntry(
                entry!.id,
                recipeId: recipeId,
                customName: customName,
                cookId: cookId,
              );
        },
      ),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, WidgetRef ref, String entryName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eintrag löschen'),
        content: Text('"$entryName" wirklich entfernen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(mealPlanActionsProvider).removeEntry(entry!.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve display name
    final String? displayName;
    if (entry == null) {
      displayName = null;
    } else if (entry!.recipeId != null) {
      displayName = ref.watch(recipeNameProvider(entry!.recipeId!)).value;
    } else {
      displayName = entry!.customName;
    }

    // Resolve cook
    final cookAsync = entry?.cookId != null
        ? ref.watch(cookUserProvider(entry!.cookId!))
        : null;
    final cook = cookAsync?.value;

    return GestureDetector(
      onTap: entry != null && entry!.recipeId != null
          ? () => context.router
              .root.push(ShowRecipeRoute(recipeId: entry!.recipeId!))
          : null,
      onLongPress: entry != null
          ? () => _openEditPicker(context, ref, displayName)
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surface.withValues(alpha: 0.3)
                    : colorScheme.surface.withValues(alpha: 0.6),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadius),
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
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          displayName ?? 'Mahlzeit hinzufügen',
                          style: textTheme.bodyLarge?.copyWith(
                            color: displayName != null
                                ? colorScheme.onSurface
                                : colorScheme.onSurface
                                    .withValues(alpha: 0.45),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Cook avatar (display only — no picker)
                  if (entry?.cookId != null) ...[
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage: cook?.imageUrl != null
                          ? CachedNetworkImageProvider(cook!.imageUrl!)
                          : null,
                      child: cook == null
                          ? Icon(Icons.hourglass_empty,
                              size: 13,
                              color: colorScheme.onPrimaryContainer)
                          : (cook.imageUrl == null
                              ? Text(
                                  cook.name.isNotEmpty
                                      ? cook.name[0].toUpperCase()
                                      : '?',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontSize: 10,
                                  ),
                                )
                              : null),
                    ),
                  ],

                  // Action button: add or delete (with confirmation)
                  if (entry != null)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      onPressed: () => _showDeleteDialog(
                          context, ref, displayName ?? mealType.displayName),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      onPressed: () => _openAddPicker(context, ref),
                    ),
                ],
              ),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 22, color: colorScheme.primary),
    );
  }
}
