import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/slot_drag_payload.dart';
import 'package:meal_planner/services/providers/meal_plan/slot_drag_provider.dart';

class WeekplanWeekStrip extends StatelessWidget {
  final DateTime weekStart; // always a Monday
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final DateTime? selectedDay;
  final ValueChanged<DateTime>? onDayTapped;

  const WeekplanWeekStrip({
    super.key,
    required this.weekStart,
    required this.onPreviousWeek,
    required this.onNextWeek,
    this.selectedDay,
    this.onDayTapped,
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
          _DwellChevron(
            icon: Icons.chevron_left,
            onPressed: onPreviousWeek,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
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
                      final isSelected = selectedDay != null &&
                          day.year == selectedDay!.year &&
                          day.month == selectedDay!.month &&
                          day.day == selectedDay!.day;

                      Color circleColor = Colors.transparent;
                      Border? circleBorder;
                      Color textColor = colorScheme.onSurface;

                      if (isSelected) {
                        circleColor =
                            colorScheme.onSurface.withValues(alpha: 0.12);
                        textColor = colorScheme.secondary;
                      }
                      if (isToday) {
                        circleBorder = Border.all(
                          color: colorScheme.primary,
                          width: 2,
                        );
                        if (!isSelected) textColor = colorScheme.onSurface;
                      }

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onDayTapped?.call(day),
                          behavior: HitTestBehavior.opaque,
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
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: circleColor,
                                  border: circleBorder,
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: textColor,
                                      fontWeight: isToday || isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          _DwellChevron(
            icon: Icons.chevron_right,
            onPressed: onNextWeek,
          ),
        ],
      ),
    );
  }
}

/// Chevron that fires [onPressed] on a normal tap and also repeatedly while
/// a meal-slot drag hovers over it: the first fire lands after
/// [dwellDuration], subsequent fires follow every [dwellDuration] for as
/// long as the pointer stays. Leaving the chevron cancels the cycle;
/// re-entering starts a fresh countdown.
class _DwellChevron extends ConsumerStatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Duration dwellDuration;

  const _DwellChevron({
    required this.icon,
    required this.onPressed,
    this.dwellDuration = const Duration(seconds: 1),
  });

  @override
  ConsumerState<_DwellChevron> createState() => _DwellChevronState();
}

class _DwellChevronState extends ConsumerState<_DwellChevron> {
  Timer? _dwellTimer;
  bool _isHovering = false;

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }

  void _onEnter() {
    if (_dwellTimer != null) return;
    setState(() => _isHovering = true);
    ref.read(isHoveringChevronProvider.notifier).value = true;
    _dwellTimer = Timer.periodic(widget.dwellDuration, (_) {
      widget.onPressed();
    });
  }

  void _onLeave() {
    _dwellTimer?.cancel();
    _dwellTimer = null;
    if (_isHovering) {
      setState(() => _isHovering = false);
    }
    ref.read(isHoveringChevronProvider.notifier).value = false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DragTarget<SlotDragPayload>(
      onWillAcceptWithDetails: (_) => false,
      onMove: (_) => _onEnter(),
      onLeave: (_) => _onLeave(),
      builder: (_, __, ___) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isHovering
              ? colorScheme.primary.withValues(alpha: 0.18)
              : Colors.transparent,
          border: _isHovering
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: IconButton(
          icon: Icon(widget.icon),
          color: _isHovering ? colorScheme.primary : null,
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
