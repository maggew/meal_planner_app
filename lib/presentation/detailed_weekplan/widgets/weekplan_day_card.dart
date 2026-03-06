import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_recipe_picker.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';
import 'package:meal_planner/services/providers/user/group_settings_provider.dart';

class WeekplanDayCard extends ConsumerWidget {
  final DateTime date;

  const WeekplanDayCard({super.key, required this.date});

  /// Minimum rendered height: vertical margin (14) + vertical padding (36) + header row (~20)
  static const double minHeight = 70;

  static const _weekdayShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  static const _mealIcons = {
    MealType.breakfast: Icons.wb_sunny_outlined,
    MealType.lunch: Icons.lunch_dining,
    MealType.dinner: Icons.nights_stay_outlined,
  };

  void _openAddPicker(BuildContext context, WidgetRef ref, MealType mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WeekplanRecipePicker(
        date: date,
        mealType: mealType,
        onSelected: (recipeId, customName, cookIds) {
          ref.read(mealPlanActionsProvider).addEntry(
                date: date,
                mealType: mealType,
                recipeId: recipeId,
                customName: customName,
                cookIds: cookIds,
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
    final mealSlots = ref.watch(groupSettingsProvider).defaultMealSlots;
    final hasAnyEntry = entries.any((e) => mealSlots.contains(e.mealType));

    final dayLabel = _weekdayShort[date.weekday - 1];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 8, 18),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surface.withValues(alpha: 0.3)
                  : colorScheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              border: Border.all(
                color: isToday
                    ? colorScheme.secondary
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
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isToday
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (!hasAnyEntry)
                      ...mealSlots.map(
                        (type) => _CompactAddButton(
                          icon: _mealIcons[type]!,
                          onTap: () => _openAddPicker(context, ref, type),
                        ),
                      ),
                  ],
                ),
                if (hasAnyEntry) ...[
                  const SizedBox(height: 14),
                  ...mealSlots.map((type) {
                    final entry =
                        entries.where((e) => e.mealType == type).firstOrNull;
                    if (entry != null) {
                      return _MealRow(
                        entry: entry,
                        icon: _mealIcons[type]!,
                        date: date,
                      );
                    } else {
                      return _EmptySlotRow(
                        icon: _mealIcons[type]!,
                        onTap: () => _openAddPicker(context, ref, type),
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
      icon: Icon(icon, size: 22),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon,
                size: 20, color: colorScheme.onSurface.withValues(alpha: 0.25)),
            const SizedBox(width: 8),
            Icon(Icons.add,
                size: 18, color: colorScheme.onSurface.withValues(alpha: 0.25)),
          ],
        ),
      ),
    );
  }
}

class _MealRow extends ConsumerWidget {
  final MealPlanEntry entry;
  final IconData icon;
  final DateTime date;

  const _MealRow({
    required this.entry,
    required this.icon,
    required this.date,
  });

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eintrag löschen'),
        content: const Text('Diesen Eintrag wirklich entfernen?'),
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
      ref.read(mealPlanActionsProvider).removeEntry(entry.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final String? displayName;
    if (entry.recipeId != null) {
      final nameAsync = ref.watch(recipeNameProvider(entry.recipeId!));
      displayName = nameAsync.value;
    } else {
      displayName = entry.customName;
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => WeekplanRecipePicker(
            date: date,
            mealType: entry.mealType,
            initialLabel: displayName,
            initialRecipeId: entry.recipeId,
            initialCustomName: entry.customName,
            initialCookIds: entry.cookIds,
            onSelected: (recipeId, customName, cookIds) {
              ref.read(mealPlanActionsProvider).updateEntry(
                    entry.id,
                    recipeId: recipeId,
                    customName: customName,
                    cookIds: cookIds,
                  );
            },
          ),
        );
      },
      onLongPress: () {
        if (entry.recipeId != null) {
          context.router.root.push(ShowRecipeRoute(recipeId: entry.recipeId!));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            if (entry.cookIds.isNotEmpty) ...[
              const SizedBox(width: 6),
              _CookAvatarStack(cookIds: entry.cookIds),
            ],
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                displayName ?? '…',
                style: textTheme.bodyLarge?.copyWith(
                  color: entry.recipeId != null
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ),
            if (entry.recipeId != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.menu_book_outlined,
                size: 15,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ],
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _showDeleteDialog(context, ref),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CookAvatarStack extends ConsumerWidget {
  final List<String> cookIds;
  const _CookAvatarStack({required this.cookIds});

  static const double _radius = 11;
  static const double _overlap = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final avatars = cookIds
        .map((id) => ref.watch(cookUserProvider(id)).value)
        .toList();

    final width =
        _radius * 2 + (cookIds.length - 1) * (_radius * 2 - _overlap);

    return SizedBox(
      width: width,
      height: _radius * 2,
      child: Stack(
        children: List.generate(avatars.length, (i) {
          final user = avatars[i];
          return Positioned(
            left: i * (_radius * 2 - _overlap),
            child: CircleAvatar(
              radius: _radius,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: user?.imageUrl != null
                  ? NetworkImage(user!.imageUrl!)
                  : null,
              child: user?.imageUrl == null
                  ? Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
