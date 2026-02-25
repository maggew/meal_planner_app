import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/presentation/detailes_weekplan/widgets/weekplan_cook_picker.dart';
import 'package:meal_planner/presentation/detailes_weekplan/widgets/weekplan_recipe_picker.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';

class WeekplanDayCard extends ConsumerWidget {
  final DateTime date;

  const WeekplanDayCard({super.key, required this.date});

  static const _weekdayShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  static const _mealIcons = {
    MealType.breakfast: Icons.wb_sunny_outlined,
    MealType.lunch: Icons.lunch_dining,
    MealType.dinner: Icons.nights_stay_outlined,
  };

  void _openPicker(BuildContext context, WidgetRef ref, MealType mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WeekplanRecipePicker(
        onSelected: (recipeId) {
          ref.read(mealPlanActionsProvider).addEntry(
                date: date,
                mealType: mealType,
                recipeId: recipeId,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    final entriesAsync = ref.watch(mealPlanStreamProvider(date));
    final entries = entriesAsync.value ?? [];
    final hasAnyEntry = entries.isNotEmpty;

    final dayLabel = _weekdayShort[date.weekday - 1];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surface.withValues(alpha: 0.3)
                  : colorScheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              border: Border.all(
                color: isToday
                    ? colorScheme.primary.withValues(alpha: 0.5)
                    : colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$dayLabel, ${date.day}.${date.month}.',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isToday
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (!hasAnyEntry)
                      ...MealType.values.map(
                        (type) => _CompactAddButton(
                          icon: _mealIcons[type]!,
                          onTap: () => _openPicker(context, ref, type),
                        ),
                      ),
                  ],
                ),
                if (hasAnyEntry) ...[
                  const SizedBox(height: 8),
                  ...MealType.values.map((type) {
                    final entry =
                        entries.where((e) => e.mealType == type).firstOrNull;
                    if (entry != null) {
                      return _MealRow(
                        entry: entry,
                        mealType: type,
                        icon: _mealIcons[type]!,
                      );
                    } else {
                      return _EmptySlotRow(
                        icon: _mealIcons[type]!,
                        onTap: () => _openPicker(context, ref, type),
                      );
                    }
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactAddButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CompactAddButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(icon, size: 18),
      color: colorScheme.onSurface.withValues(alpha: 0.35),
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      constraints: const BoxConstraints(),
    );
  }
}

class _EmptySlotRow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _EmptySlotRow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 15,
                color: colorScheme.onSurface.withValues(alpha: 0.25)),
            const SizedBox(width: 8),
            Icon(Icons.add, size: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.25)),
          ],
        ),
      ),
    );
  }
}

class _MealRow extends ConsumerWidget {
  final MealPlanEntry entry;
  final MealType mealType;
  final IconData icon;

  const _MealRow({
    required this.entry,
    required this.mealType,
    required this.icon,
  });

  void _openCookPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WeekplanCookPicker(
        currentCookId: entry.cookId,
        onSelected: (userId) =>
            ref.read(mealPlanActionsProvider).setCook(entry.id, userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final nameAsync = ref.watch(recipeNameProvider(entry.recipeId));
    final recipeName = nameAsync.value;

    final cookAsync =
        entry.cookId != null ? ref.watch(cookUserProvider(entry.cookId!)) : null;
    final cook = cookAsync?.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '${mealType.displayName}  ',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          Expanded(
            child: Text(
              recipeName ?? '…',
              style: textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _openCookPicker(context, ref),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: cook?.imageUrl != null
                  ? CachedNetworkImageProvider(cook!.imageUrl!)
                  : null,
              child: cook == null
                  ? Icon(
                      entry.cookId != null
                          ? Icons.hourglass_empty
                          : Icons.person_add_outlined,
                      size: 13,
                      color: colorScheme.onPrimaryContainer,
                    )
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
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: () =>
                ref.read(mealPlanActionsProvider).removeEntry(entry.id),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 15,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
