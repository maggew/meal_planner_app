import 'package:flutter/material.dart';

class WeekplanWeekStrip extends StatelessWidget {
  final DateTime weekStart; // always a Monday
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const WeekplanWeekStrip({
    super.key,
    required this.weekStart,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  static const _weekdayShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

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

  String _monthLabel() {
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (weekEnd.month != weekStart.month) {
      return '${_monthNames[weekStart.month - 1]} / ${_monthNames[weekEnd.month - 1]}';
    }
    return _monthNames[weekStart.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final today = DateTime.now();

    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousWeek,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
              child: Column(
                children: [
                  Text(
                    _monthLabel(),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: days.map((day) {
                      final isToday = day.year == today.year &&
                          day.month == today.month &&
                          day.day == today.day;

                      return Expanded(
                        child: Column(
                          children: [
                            Text(
                              _weekdayShort[day.weekday - 1],
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isToday
                                    ? colorScheme.primary
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: isToday
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                    fontWeight: isToday
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextWeek,
          ),
        ],
      ),
    );
  }
}
