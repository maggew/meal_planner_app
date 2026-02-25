import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/detailes_weekplan/widgets/weekplan_meal_card.dart';

class WeekplanDayMealsSection extends StatelessWidget {
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

  static const _mealSlots = [
    (label: 'Frühstück', icon: Icons.wb_sunny_outlined),
    (label: 'Mittagessen', icon: Icons.lunch_dining),
    (label: 'Abendessen', icon: Icons.nights_stay_outlined),
  ];

  String _formatDay(DateTime day) {
    return '${_weekdayLong[day.weekday - 1]}, ${day.day}. ${_monthNames[day.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
          child: Text(
            _formatDay(selectedDay),
            style: textTheme.titleSmall,
          ),
        ),
        ..._mealSlots.map(
          (meal) => WeekplanMealCard(mealType: meal.label, icon: meal.icon),
        ),
      ],
    );
  }
}
