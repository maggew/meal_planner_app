import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/timer/cooking_mode_active_timer.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/timer/cooking_mode_idle_timer.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/recipe_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';

class CookingModeTimerWidget extends ConsumerStatefulWidget {
  final String recipeId;
  final int stepIndex;
  final double pageMargin;
  final double borderRadius;
  final bool forceShowPicker;
  final VoidCallback? onPickerClosed;

  const CookingModeTimerWidget({
    super.key,
    required this.recipeId,
    required this.stepIndex,
    required this.pageMargin,
    required this.borderRadius,
    this.forceShowPicker = false,
    this.onPickerClosed,
  });

  @override
  ConsumerState<CookingModeTimerWidget> createState() =>
      _CookingModeTimerWidgetState();
}

class _CookingModeTimerWidgetState extends ConsumerState<CookingModeTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _timerKey => '${widget.recipeId}:${widget.stepIndex}';

  @override
  Widget build(BuildContext context) {
    // Tick watchen für sekündliche UI-Updates
    ref.watch(timerTickProvider);

    final activeTimers = ref.watch(activeTimerProvider);
    final activeTimer = activeTimers[_timerKey];
    final savedTimers = ref.watch(recipeTimersProvider(widget.recipeId));

    // Pulse-Animation steuern
    if (activeTimer?.status == TimerStatus.finished) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.reset();
    }

    final hasSaved = savedTimers.value?[widget.stepIndex] != null;
    if (activeTimer == null && !hasSaved && !widget.forceShowPicker) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final isFinished = activeTimer?.status == TimerStatus.finished;
        final pulseValue = _pulseController.value;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: widget.pageMargin),
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isFinished
                ? Color.lerp(Colors.white, Colors.green[50], pulseValue)
                : Colors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: isFinished
                ? Border.all(
                    color: Colors.green
                        .withValues(alpha: 0.3 + (pulseValue * 0.4)),
                    width: 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: isFinished
                    ? Colors.green.withValues(alpha: 0.15 + (pulseValue * 0.15))
                    : Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 0.0,
                offset: const Offset(5.0, 5.0),
              ),
            ],
          ),
          child: child,
        );
      },
      child: activeTimer != null
          ? CookingModeActiveTimer(timer: activeTimer, timerKey: _timerKey)
          : CookingModeIdleTimer(
              forceShowPicker: widget.forceShowPicker,
              stepIndex: widget.stepIndex,
              recipeId: widget.recipeId,
              saved: savedTimers.value?[widget.stepIndex],
              onPickerClosed: widget.onPickerClosed,
            ),
    );
  }
}
