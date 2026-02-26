import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_day_card.dart';

class WeekplanWeekList extends StatelessWidget {
  final DateTime weekStart;
  final GlobalKey? todayKey;

  const WeekplanWeekList({
    super.key,
    required this.weekStart,
    this.todayKey,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    return Column(
      children: days.map((day) {
        final isToday = day.year == today.year &&
            day.month == today.month &&
            day.day == today.day;
        return WeekplanDayCard(
          key: isToday ? todayKey : null,
          date: day,
        );
      }).toList(),
    );
  }
}
