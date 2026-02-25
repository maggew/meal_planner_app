import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';

class WeekplanCalendar extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const WeekplanCalendar({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  static const _monthNames = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];

  static const _weekdayShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: AppDimensions.borderRadiusAll,
      ),
      child: Column(
        children: [
          _CalendarHeader(
            focusedMonth: focusedMonth,
            monthNames: _monthNames,
            textTheme: textTheme,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
          ),
          _WeekdayLabels(
            weekdayShort: _weekdayShort,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 6),
          _CalendarGrid(
            focusedMonth: focusedMonth,
            selectedDay: selectedDay,
            onDaySelected: onDaySelected,
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedMonth;
  final List<String> monthNames;
  final TextTheme textTheme;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const _CalendarHeader({
    required this.focusedMonth,
    required this.monthNames,
    required this.textTheme,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousMonth,
          ),
          Expanded(
            child: Text(
              '${monthNames[focusedMonth.month - 1]} ${focusedMonth.year}',
              textAlign: TextAlign.center,
              style: textTheme.titleSmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}

class _WeekdayLabels extends StatelessWidget {
  final List<String> weekdayShort;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _WeekdayLabels({
    required this.weekdayShort,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekdayShort.map((name) {
          return Expanded(
            child: Center(
              child: Text(
                name,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final today = DateTime.now();

    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final leadingBlanks = focusedMonth.weekday - 1; // weekday: 1=Mon, 7=Sun
    final rows = ((leadingBlanks + daysInMonth) / 7).ceil();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0,
        ),
        itemCount: rows * 7,
        itemBuilder: (context, index) {
          final dayNumber = index - leadingBlanks + 1;
          if (dayNumber < 1 || dayNumber > daysInMonth) {
            return const SizedBox.shrink();
          }

          final day =
              DateTime(focusedMonth.year, focusedMonth.month, dayNumber);
          final isToday = day.year == today.year &&
              day.month == today.month &&
              day.day == today.day;
          final isSelected = day.year == selectedDay.year &&
              day.month == selectedDay.month &&
              day.day == selectedDay.day;

          return GestureDetector(
            onTap: () => onDaySelected(day),
            child: AnimatedContainer(
              duration: AppDimensions.animationDuration,
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colorScheme.primary : Colors.transparent,
                border: isToday && !isSelected
                    ? Border.all(color: colorScheme.primary, width: 1.5)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$dayNumber',
                  style: textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: isToday || isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
