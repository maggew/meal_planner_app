import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/detailes_weekplan/widgets/weekplan_day_card.dart';

class WeekplanWeekList extends StatelessWidget {
  final DateTime weekStart;

  const WeekplanWeekList({super.key, required this.weekStart});

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    return Column(
      children: days.map((day) => WeekplanDayCard(date: day)).toList(),
    );
  }
}
