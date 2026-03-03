import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';
import 'package:meal_planner/services/providers/user/group_settings_provider.dart';

class WeekplanDaySummaryCard extends ConsumerWidget {
  final DateTime selectedDay;

  const WeekplanDaySummaryCard({super.key, required this.selectedDay});

  static const _weekdayLong = [
    'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
    'Freitag', 'Samstag', 'Sonntag',
  ];

  static const _monthNames = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
  ];

  String _formatDay(DateTime day) =>
      '${_weekdayLong[day.weekday - 1]}, ${day.day}. ${_monthNames[day.month - 1]}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final entriesAsync = ref.watch(mealPlanStreamProvider(selectedDay));
    final mealSlots = ref.watch(groupSettingsProvider).defaultMealSlots;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: AppDimensions.borderRadiusAll,
      ),
      child: entriesAsync.when(
        data: (entries) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDay(selectedDay), style: textTheme.titleSmall),
            const SizedBox(height: 8),
            ...mealSlots.map(
              (type) => _SummaryRow(
                type: type,
                entry: entries.where((e) => e.mealType == type).firstOrNull,
              ),
            ),
          ],
        ),
        loading: () => Text(_formatDay(selectedDay), style: textTheme.titleSmall),
        error: (_, __) => Text(_formatDay(selectedDay), style: textTheme.titleSmall),
      ),
    );
  }
}

class _SummaryRow extends ConsumerWidget {
  final MealType type;
  final MealPlanEntry? entry;

  const _SummaryRow({required this.type, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final String? recipeName;
    if (entry == null) {
      recipeName = null;
    } else if (entry!.recipeId != null) {
      recipeName = ref.watch(recipeNameProvider(entry!.recipeId!)).value;
    } else {
      recipeName = entry!.customName;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '${type.displayName}:  ',
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          Expanded(
            child: Text(
              recipeName ?? '–',
              style: textTheme.bodySmall?.copyWith(
                color: recipeName != null
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
