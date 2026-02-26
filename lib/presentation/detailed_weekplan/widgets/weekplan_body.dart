import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_week_list.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_week_strip.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_sync_provider.dart';

class WeekplanBody extends ConsumerStatefulWidget {
  const WeekplanBody({super.key});

  @override
  ConsumerState<WeekplanBody> createState() => _WeekplanBodyState();
}

class _WeekplanBodyState extends ConsumerState<WeekplanBody> {
  late DateTime _weekStart; // always a Monday

  @override
  void initState() {
    super.initState();
    _weekStart = _mondayOf(DateTime.now());
  }

  static DateTime _mondayOf(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  void _onPreviousWeek() {
    final newWeekStart = _weekStart.subtract(const Duration(days: 7));
    setState(() => _weekStart = newWeekStart);
    _syncForWeek(newWeekStart);
  }

  void _onNextWeek() {
    final newWeekStart = _weekStart.add(const Duration(days: 7));
    setState(() => _weekStart = newWeekStart);
    _syncForWeek(newWeekStart);
  }

  void _syncForWeek(DateTime weekStart) {
    final sync = ref.read(mealPlanSyncServiceProvider);
    sync.sync(weekStart.year, weekStart.month);
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (weekEnd.month != weekStart.month) {
      sync.sync(weekEnd.year, weekEnd.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: 24),
        child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeekplanWeekStrip(
            weekStart: _weekStart,
            onPreviousWeek: _onPreviousWeek,
            onNextWeek: _onNextWeek,
          ),
          WeekplanWeekList(weekStart: _weekStart),
        ],
      ),
      ),
    );
  }
}
