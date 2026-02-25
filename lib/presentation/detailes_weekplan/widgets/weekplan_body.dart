import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/detailes_weekplan/widgets/weekplan_calendar.dart';
import 'package:meal_planner/presentation/detailes_weekplan/widgets/weekplan_day_meals_section.dart';

class WeekplanBody extends StatefulWidget {
  const WeekplanBody({super.key});

  @override
  State<WeekplanBody> createState() => _WeekplanBodyState();
}

class _WeekplanBodyState extends State<WeekplanBody> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = now;
    _focusedMonth = DateTime(now.year, now.month, 1);
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDay = day;
      _focusedMonth = DateTime(day.year, day.month, 1);
    });
  }

  void _onPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _onNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeekplanCalendar(
            focusedMonth: _focusedMonth,
            selectedDay: _selectedDay,
            onDaySelected: _onDaySelected,
            onPreviousMonth: _onPreviousMonth,
            onNextMonth: _onNextMonth,
          ),
          WeekplanDayMealsSection(selectedDay: _selectedDay),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
