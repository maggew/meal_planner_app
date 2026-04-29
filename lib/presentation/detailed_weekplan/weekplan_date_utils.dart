import 'package:meal_planner/domain/enums/week_start_day.dart';

/// Returns the Monday or Sunday that starts the week containing [date].
DateTime weekStartOf(DateTime date, WeekStartDay weekStartDay) {
  return switch (weekStartDay) {
    WeekStartDay.monday => date.subtract(Duration(days: date.weekday - 1)),
    WeekStartDay.sunday => date.subtract(Duration(days: date.weekday % 7)),
  };
}

/// True when any day in the 7-day week starting at [weekStart] is today.
bool weekContainsToday(DateTime weekStart) {
  final today = DateTime.now();
  return List.generate(7, (i) => weekStart.add(Duration(days: i))).any((d) =>
      d.year == today.year && d.month == today.month && d.day == today.day);
}
