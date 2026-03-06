import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_day_card.dart';

class WeekplanWeekList extends StatelessWidget {
  final DateTime weekStart;
  final List<GlobalKey> dayKeys;

  const WeekplanWeekList({
    super.key,
    required this.weekStart,
    required this.dayKeys,
  });

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    return Column(
      children: List.generate(days.length, (i) {
        return WeekplanDayCard(
          key: dayKeys[i],
          date: days[i],
        );
      }),
    );
  }
}
