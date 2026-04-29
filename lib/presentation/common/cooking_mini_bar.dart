import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/presentation/common/glass_card.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/cooking/active_cooking_session_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';

class CookingMiniBar extends ConsumerStatefulWidget {
  const CookingMiniBar({super.key});

  @override
  ConsumerState<CookingMiniBar> createState() => _CookingMiniBarState();
}

class _CookingMiniBarState extends ConsumerState<CookingMiniBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;

  // Cache values so content stays valid during reverse animation
  String? _cachedRecipeId;
  String _cachedDisplayName = '';
  String? _cachedTimerText;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDimensions.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeCookingSessionProvider);
    final shouldShow = session.isActive && session.wasInCookingMode;

    Map<String, ActiveTimer> timers = const {};
    if (shouldShow) {
      _controller.forward();

      ref.watch(timerTickProvider);
      timers = ref.watch(activeTimerProvider);

      final recipeCount = session.recipes.length;
      _cachedDisplayName = recipeCount == 1
          ? session.recipes.first.recipeName
          : '$recipeCount Rezepte';

      final sessionRecipeIds =
          session.recipes.map((e) => e.recipeId).toSet();
      _cachedTimerText = _shortestTimerText(timers, sessionRecipeIds);
      _cachedRecipeId = session.currentRecipeId;
    } else {
      _controller.reverse();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final sessionRecipeIds = session.recipes.map((e) => e.recipeId).toSet();
    final hasRunningTimer = timers.values.any(
      (t) =>
          sessionRecipeIds.contains(t.recipeId) &&
          (t.status == TimerStatus.running ||
              t.status == TimerStatus.paused ||
              t.status == TimerStatus.finished),
    );
    final showCloseButton =
        session.recipes.length == 1 && !hasRunningTimer;

    return SizeTransition(
      sizeFactor: _animation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: GestureDetector(
            onTap: () {
              if (_cachedRecipeId != null) {
                context.router.root
                    .push(ShowRecipeRoute(recipeId: _cachedRecipeId!));
              }
            },
            child: GlassCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.restaurant,
                      size: 20, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _cachedDisplayName,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_cachedTimerText != null)
                    Text(
                      _cachedTimerText!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(width: 4),
                  if (showCloseButton)
                    GestureDetector(
                      onTap: () => ref
                          .read(activeCookingSessionProvider.notifier)
                          .clearSession(),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _shortestTimerText(
    Map<String, ActiveTimer> timers,
    Set<String> recipeIds,
  ) {
    int? shortest;
    for (final timer in timers.values) {
      if (!recipeIds.contains(timer.recipeId)) continue;
      if (timer.status == TimerStatus.finished) return '\u23F0';
      if (timer.status != TimerStatus.running) continue;
      final remaining = timer.remainingSeconds;
      if (shortest == null || remaining < shortest) {
        shortest = remaining;
      }
    }
    if (shortest == null) return null;
    final m = shortest ~/ 60;
    final s = shortest % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
