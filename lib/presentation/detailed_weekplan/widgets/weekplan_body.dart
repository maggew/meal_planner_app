import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_week_list.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_week_strip.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_sync_provider.dart';

class WeekplanBody extends ConsumerStatefulWidget {
  const WeekplanBody({super.key});

  @override
  ConsumerState<WeekplanBody> createState() => _WeekplanBodyState();
}

class _WeekplanBodyState extends ConsumerState<WeekplanBody> {
  late DateTime _weekStart; // always a Monday
  final _scrollController = ScrollController();
  final _todayKey = GlobalKey();
  final _contentKey = GlobalKey();
  bool _hasScrolledToToday = false;

  @override
  void initState() {
    super.initState();
    _weekStart = _mondayOf(DateTime.now());
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
    if (!_scrollController.hasClients) return;
    final todayCtx = _todayKey.currentContext;
    if (todayCtx == null) return;
    final contentCtx = _contentKey.currentContext;
    if (contentCtx == null) return;
    final todayBox = todayCtx.findRenderObject() as RenderBox?;
    if (todayBox == null) return;
    final contentBox = contentCtx.findRenderObject() as RenderBox?;
    if (contentBox == null) return;
    // Distance from content top to today's card top = exact jumpTo target
    final todayInContent =
        contentBox.globalToLocal(todayBox.localToGlobal(Offset.zero));
    _scrollController.jumpTo(
      todayInContent.dy.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    // Scroll to today once all day-streams have emitted their first value.
    // This handles the case where Drift data loads after the initial layout.
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
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              key: _contentKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WeekplanWeekList(
                  weekStart: _weekStart,
                  todayKey: _todayKey,
                ),
                SizedBox(height: screenHeight * 0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
