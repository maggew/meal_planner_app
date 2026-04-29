import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/detailed_weekplan/week_navigation_controller.dart';
import 'package:meal_planner/presentation/detailed_weekplan/weekplan_date_utils.dart';
import 'package:meal_planner/presentation/detailed_weekplan/drag/auto_scroll_while_dragging.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_day_card.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_week_list.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_week_strip.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';
import 'package:meal_planner/services/providers/meal_plan/slot_drag_provider.dart';
import 'package:meal_planner/services/providers/sync/sync_providers.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';
import 'package:meal_planner/services/providers/user/group_settings_provider.dart';

class WeekplanBody extends ConsumerStatefulWidget {
  const WeekplanBody({super.key, required this.visibleMonth});

  /// Owned by [DetailedWeekplanPage]. The body writes to it on week navigation
  /// so the [SyncPollingMixin] can forward month changes to the coordinator.
  final ValueNotifier<DateTime> visibleMonth;

  @override
  ConsumerState<WeekplanBody> createState() => _WeekplanBodyState();
}

class _WeekplanBodyState extends ConsumerState<WeekplanBody> {
  late final WeekNavigationController _weekNav;
  final _scrollController = ScrollController();
  // Per-week day keys: during an AnimatedSwitcher week transition both the
  // outgoing and incoming WeekplanWeekList are briefly mounted, so sharing
  // one GlobalKey list between them triggers "Duplicate GlobalKeys" on the
  // frame the new week is pushed.
  final Map<DateTime, List<GlobalKey>> _dayKeysByWeek = {};
  final _contentKey = GlobalKey();

  List<GlobalKey> _keysForWeek(DateTime weekStart) {
    return _dayKeysByWeek.putIfAbsent(
      weekStart,
      () => List.generate(7, (_) => GlobalKey()),
    );
  }

  bool _hasScrolledToToday = false;
  bool _isProgrammaticScroll = false;
  DateTime? _selectedDay = DateTime.now();
  // When a dwell-driven week change happens mid-drag, AnimatedSwitcher
  // would destroy the LongPressDraggable source inside WeekplanWeekList
  // and leak drag state (the pointer-up callback never fires because the
  // draggable is gone). Freezing the switcher's key for the drag duration
  // keeps the widget tree alive so onDragEnd still runs on release.
  DateTime? _frozenWeekKey;

  @override
  void initState() {
    super.initState();
    final weekStartDay = ref.read(groupSettingsProvider).weekStartDay;
    final initialWeekStart = weekStartOf(DateTime.now(), weekStartDay);
    _weekNav = WeekNavigationController(weekStart: initialWeekStart);
    _weekNav.addListener(() => setState(() {}));
    // Align the notifier with the actual week start (may differ from DateTime.now()
    // near month boundaries) so the coordinator syncs the right month.
    widget.visibleMonth.value = initialWeekStart;
    _scrollController.addListener(_onScroll);
    // Fallback: if all streams are already cached, scroll after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasScrolledToToday) return;
      final days = List.generate(
          7, (i) => _weekNav.weekStart.add(Duration(days: i)));
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
    final days =
        List.generate(7, (i) => _weekNav.weekStart.add(Duration(days: i)));
    final index = days.indexWhere((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);
    if (index == -1) return;
    _scrollToDayIndex(index);
  }

  void _scrollToDayIndex(int index) {
    if (!_scrollController.hasClients) return;
    final dayCtx = _keysForWeek(_weekNav.weekStart)[index].currentContext;
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
    final days =
        List.generate(7, (i) => _weekNav.weekStart.add(Duration(days: i)));
    DateTime? topDay;
    final weekKeys = _keysForWeek(_weekNav.weekStart);
    for (int i = 0; i < weekKeys.length; i++) {
      final dayCtx = weekKeys[i].currentContext;
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
    final days =
        List.generate(7, (i) => _weekNav.weekStart.add(Duration(days: i)));
    final index = days.indexWhere(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day);
    if (index == -1) return;
    setState(() => _selectedDay = day);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToDayIndex(index));
  }

  void _afterWeekChanged(DateTime newWeekStart) {
    if (weekContainsToday(newWeekStart)) {
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
    _weekNav.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildWeekSlideTransition(Widget child, Animation<double> animation) {
    final key = child.key;
    final incomingDate = key is ValueKey<DateTime> ? key.value : null;
    final isIncoming = incomingDate == _weekNav.weekStart;
    final sign = _weekNav.isForwardSlide ? 1.0 : -1.0;
    // Incoming slides from +sign*1 → 0; outgoing slides from 0 → -sign*1
    // (i.e., the opposite side). Both tweens resolve to Offset.zero at
    // animation.value == 1, which matches AnimatedSwitcher's start state
    // for the outgoing child.
    final tween = isIncoming
        ? Tween<Offset>(begin: Offset(sign, 0), end: Offset.zero)
        : Tween<Offset>(begin: Offset(-sign, 0), end: Offset.zero);
    return ClipRect(
      child: SlideTransition(
        position: tween.animate(animation),
        child: child,
      ),
    );
  }

  static Widget _stackedLayoutBuilder(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) {
    // Top-align stacked weeks so the transition doesn't vertically recentre
    // when old and new content have slightly different heights.
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ...previousChildren,
        if (currentChild != null) currentChild,
      ],
    );
  }

  void _onPreviousWeek() {
    _weekNav.previous();
    _syncForWeek(_weekNav.weekStart);
    _afterWeekChanged(_weekNav.weekStart);
  }

  void _onNextWeek() {
    _weekNav.next();
    _syncForWeek(_weekNav.weekStart);
    _afterWeekChanged(_weekNav.weekStart);
  }

  void _syncForWeek(DateTime weekStart) {
    // Updating the notifier lets SyncPollingMixin forward the new month to the
    // coordinator via updateMealPlanMonth, avoiding a direct coordinator call here.
    widget.visibleMonth.value = weekStart;
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (weekEnd.month != weekStart.month) {
      // Week straddles a month boundary — also sync the next month so the
      // calendar dots for the visible week reflect remote state.
      ref.read(syncCoordinatorProvider).syncMealPlan(weekEnd);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekStart = _weekNav.weekStart;

    // React to weekStartDay changes mid-session
    ref.listen<GroupSettings>(groupSettingsProvider, (previous, next) {
      if (previous?.weekStartDay != next.weekStartDay) {
        final newWeekStart = weekStartOf(DateTime.now(), next.weekStartDay);
        _weekNav.jumpTo(newWeekStart);
        widget.visibleMonth.value = newWeekStart;
      }
    });

    // Freeze the AnimatedSwitcher key for the duration of a drag so dwell
    // navigation doesn't unmount the LongPressDraggable source.
    ref.listen<bool>(isDraggingSlotProvider, (_, isDragging) {
      setState(() {
        _frozenWeekKey = isDragging ? _weekNav.weekStart : null;
      });
    });

    // Scroll to today once all day-streams have emitted their first value.
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    for (final day in days) {
      ref.listen(mealPlanStreamProvider(day), (_, __) {
        if (_hasScrolledToToday) return;
        final allReady =
            days.every((d) => ref.read(mealPlanStreamProvider(d)).hasValue);
        if (allReady) {
          _hasScrolledToToday = true;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToToday());
        }
      });
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerUp: _safetyClearDragState,
      onPointerCancel: _safetyClearDragState,
      child: Column(
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: isDark
                    ? colorScheme.surface.withValues(alpha: 0.55)
                    : colorScheme.surface.withValues(alpha: 0.80),
                child: WeekplanWeekStrip(
                  weekStart: weekStart,
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
                return AutoScrollWhileDragging(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      key: _contentKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: _buildWeekSlideTransition,
                          layoutBuilder: _stackedLayoutBuilder,
                          child: KeyedSubtree(
                            key: ValueKey(_frozenWeekKey ?? weekStart),
                            child: WeekplanWeekList(
                              weekStart: weekStart,
                              dayKeys: _keysForWeek(weekStart),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: constraints.maxHeight -
                                WeekplanDayCard.minHeight),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _safetyClearDragState(PointerEvent _) {
    if (!ref.read(isDraggingSlotProvider)) return;
    // A pointer came up while the drag flag is still true: the
    // LongPressDraggable's onDragEnd callback missed this release (usually
    // because its source was unmounted mid-drag). Force-clean both flags so
    // the UI doesn't stay pinned in drag mode with orange hover borders.
    ref.read(isDraggingSlotProvider.notifier).value = false;
    ref.read(isHoveringChevronProvider.notifier).value = false;
  }
}
