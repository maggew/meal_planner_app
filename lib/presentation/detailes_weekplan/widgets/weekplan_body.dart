import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/detailes_weekplan/widgets/weekplan_calendar.dart';
import 'package:meal_planner/presentation/detailes_weekplan/widgets/weekplan_day_meals_section.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_sync_provider.dart';

class WeekplanBody extends ConsumerStatefulWidget {
  const WeekplanBody({super.key});

  @override
  ConsumerState<WeekplanBody> createState() => _WeekplanBodyState();
}

class _WeekplanBodyState extends ConsumerState<WeekplanBody> {
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
    final newMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    setState(() => _focusedMonth = newMonth);
    ref
        .read(mealPlanSyncServiceProvider)
        .sync(newMonth.year, newMonth.month);
  }

  void _onNextMonth() {
    final newMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    setState(() => _focusedMonth = newMonth);
    ref
        .read(mealPlanSyncServiceProvider)
        .sync(newMonth.year, newMonth.month);
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
