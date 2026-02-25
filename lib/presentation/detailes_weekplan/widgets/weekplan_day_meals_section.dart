import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/presentation/detailes_weekplan/widgets/weekplan_meal_card.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';

class WeekplanDayMealsSection extends ConsumerWidget {
  final DateTime selectedDay;

  const WeekplanDayMealsSection({super.key, required this.selectedDay});

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
    final textTheme = Theme.of(context).textTheme;
    final entriesAsync = ref.watch(mealPlanStreamProvider(selectedDay));

    return entriesAsync.when(
      data: (entries) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
            child: Text(_formatDay(selectedDay), style: textTheme.titleSmall),
          ),
          ...MealType.values.map((type) {
            final entry =
                entries.where((e) => e.mealType == type).firstOrNull;
            return WeekplanMealCard(
              mealType: type,
              entry: entry,
              selectedDay: selectedDay,
            );
          }),
        ],
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
