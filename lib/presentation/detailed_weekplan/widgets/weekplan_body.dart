import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/enums/week_start_day.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_day_card.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_week_list.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_week_strip.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_sync_provider.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';
import 'package:meal_planner/services/providers/user/group_settings_provider.dart';

class WeekplanBody extends ConsumerStatefulWidget {
  const WeekplanBody({super.key});

  @override
  ConsumerState<WeekplanBody> createState() => _WeekplanBodyState();
}

class _WeekplanBodyState extends ConsumerState<WeekplanBody> {
  late DateTime _weekStart;
  final _scrollController = ScrollController();
  final _dayKeys = List.generate(7, (_) => GlobalKey());
  final _contentKey = GlobalKey();
  bool _hasScrolledToToday = false;
  bool _isProgrammaticScroll = false;
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    final weekStartDay = ref.read(groupSettingsProvider).weekStartDay;
    _weekStart = _weekStartOf(DateTime.now(), weekStartDay);
    _scrollController.addListener(_onScroll);
    // Fallback: if all streams are already cached, scroll after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasScrolledToToday) return;
      final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
      final allReady =
          days.every((d) => ref.read(mealPlanStreamProvider(d)).hasValue);
      if (allReady) {
        _hasScrolledToToday = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
      }
    });
  }

  void _scrollToToday() {
    final today = DateTime.now();
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final index = days.indexWhere((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);
    if (index == -1) return;
    _scrollToDayIndex(index);
  }

  void _scrollToDayIndex(int index) {
    if (!_scrollController.hasClients) return;
    final dayCtx = _dayKeys[index].currentContext;
    if (dayCtx == null) return;
    final contentCtx = _contentKey.currentContext;
    if (contentCtx == null) return;
    final dayBox = dayCtx.findRenderObject() as RenderBox?;
    if (dayBox == null) return;
    final contentBox = contentCtx.findRenderObject() as RenderBox?;
    if (contentBox == null) return;
    final dayInContent =
        contentBox.globalToLocal(dayBox.localToGlobal(Offset.zero));
    _isProgrammaticScroll = true;
    _scrollController
        .animateTo(
          dayInContent.dy.clamp(
            _scrollController.position.minScrollExtent,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .whenComplete(() {
      if (mounted) _isProgrammaticScroll = false;
    });
  }

  void _onScroll() {
    if (_isProgrammaticScroll) return;
    if (!_scrollController.hasClients) return;
    final contentBox =
        _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (contentBox == null) return;
    final scrollOffset = _scrollController.offset;
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    DateTime? topDay;
    for (int i = 0; i < _dayKeys.length; i++) {
      final dayCtx = _dayKeys[i].currentContext;
      if (dayCtx == null) continue;
      final dayBox = dayCtx.findRenderObject() as RenderBox?;
      if (dayBox == null) continue;
      final dayTop =
          contentBox.globalToLocal(dayBox.localToGlobal(Offset.zero)).dy;
      if (dayTop <= scrollOffset + 60) topDay = days[i];
    }
    if (topDay != null && topDay != _selectedDay) {
      setState(() => _selectedDay = topDay);
    }
  }

  void _onDayTapped(DateTime day) {
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final index = days.indexWhere(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day);
    if (index == -1) return;
    setState(() => _selectedDay = day);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToDayIndex(index));
  }

  bool _weekContainsToday(DateTime weekStart) {
    final today = DateTime.now();
    return List.generate(7, (i) => weekStart.add(Duration(days: i))).any((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);
  }

  void _afterWeekChanged(DateTime newWeekStart) {
    if (_weekContainsToday(newWeekStart)) {
      final today = DateTime.now();
      setState(() => _selectedDay = today);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
    } else {
      setState(() => _selectedDay = null);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static DateTime _weekStartOf(DateTime date, WeekStartDay weekStartDay) {
    return switch (weekStartDay) {
      WeekStartDay.monday => date.subtract(Duration(days: date.weekday - 1)),
      WeekStartDay.sunday => date.subtract(Duration(days: date.weekday % 7)),
    };
  }

  void _onPreviousWeek() {
    final newWeekStart = _weekStart.subtract(const Duration(days: 7));
    setState(() => _weekStart = newWeekStart);
    _syncForWeek(newWeekStart);
    _afterWeekChanged(newWeekStart);
  }

  void _onNextWeek() {
    final newWeekStart = _weekStart.add(const Duration(days: 7));
    setState(() => _weekStart = newWeekStart);
    _syncForWeek(newWeekStart);
    _afterWeekChanged(newWeekStart);
  }

  void _syncForWeek(DateTime weekStart) {
    final sync = ref.read(mealPlanSyncServiceProvider);
    sync.updateMonth(weekStart.year, weekStart.month);
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (weekEnd.month != weekStart.month) {
      sync.pullRemoteForMonth(weekEnd.year, weekEnd.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // React to weekStartDay changes mid-session
    ref.listen<GroupSettings>(groupSettingsProvider, (previous, next) {
      if (previous?.weekStartDay != next.weekStartDay) {
        setState(() {
          _weekStart = _weekStartOf(DateTime.now(), next.weekStartDay);
        });
      }
    });

    // Scroll to today once all day-streams have emitted their first value.
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    for (final day in days) {
      ref.listen(mealPlanStreamProvider(day), (_, __) {
        if (_hasScrolledToToday) return;
        final allReady =
            days.every((d) => ref.read(mealPlanStreamProvider(d)).hasValue);
        if (allReady) {
          _hasScrolledToToday = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
        }
      });
    }

    return Column(
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: isDark
                  ? colorScheme.surface.withValues(alpha: 0.55)
                  : colorScheme.surface.withValues(alpha: 0.80),
              child: WeekplanWeekStrip(
                weekStart: _weekStart,
                onPreviousWeek: _onPreviousWeek,
                onNextWeek: _onNextWeek,
                selectedDay: _selectedDay,
                onDayTapped: _onDayTapped,
              ),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  key: _contentKey,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WeekplanWeekList(
                      weekStart: _weekStart,
                      dayKeys: _dayKeys,
                    ),
                    SizedBox(height: constraints.maxHeight - WeekplanDayCard.minHeight),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
