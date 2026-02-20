import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/timer/cooking_mode_active_timer.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/timer/cooking_mode_idle_timer.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/recipe_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';

class CookingModeTimerWidget extends ConsumerStatefulWidget {
  final String recipeId;
  final int stepIndex;
  final bool forceShowPicker;
  final VoidCallback? onPickerClosed;

  const CookingModeTimerWidget({
    super.key,
    required this.recipeId,
    required this.stepIndex,
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

    final isFinished = activeTimer?.status == TimerStatus.finished;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainer;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseValue = _pulseController.value;

        final finishedColor =
            Color.lerp(baseColor, colorScheme.primaryContainer, pulseValue);

        return Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isFinished ? finishedColor : baseColor,
            borderRadius: AppDimensions.borderRadiusAll,
            border: isFinished
                ? Border.all(
                    color: colorScheme.primary
                        .withValues(alpha: 0.3 + (pulseValue * 0.4)),
                    width: 2,
                  )
                : Border(
                    left: BorderSide(
                      color: colorScheme.primary,
                      width: 4,
                    ),
                  ),
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
