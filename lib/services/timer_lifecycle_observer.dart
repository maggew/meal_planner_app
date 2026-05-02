import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';
import 'package:meal_planner/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pendingActionsKey = 'pending_timer_actions';

class TimerLifecycleObserver extends WidgetsBindingObserver {
  final WidgetRef ref;

  TimerLifecycleObserver(this.ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onResumed();
    } else if (state == AppLifecycleState.paused) {
      _onPaused();
    }
  }

  Future<void> _onResumed() async {
    await _processPendingBackgroundActions();

    final timers = ref.read(activeTimerProvider);
    if (timers.isEmpty) return;

    // Find timer keys that expired while the app was backgrounded.
    final expiredKeys = timers.entries
        .where((e) => e.value.isExpired)
        .map((e) => e.key)
        .toSet();

    // Determine which of those timers had their alarm notification swiped away.
    // If swiped, the user already acknowledged it — skip sound and new notification.
    Set<String> dismissedKeys = const {};
    if (expiredKeys.isNotEmpty) {
      final activeIds =
          await NotificationService.instance.getActiveNotificationIds();
      dismissedKeys = expiredKeys
          .where((key) => !activeIds
              .contains(NotificationService.alarmNotificationIdForKey(key)))
          .toSet();
    }

    ref
        .read(activeTimerProvider.notifier)
        .checkExpiredTimers(dismissedKeys: dismissedKeys);

    final updatedTimers = ref.read(activeTimerProvider);

    // Re-ensure sound for timers that were already finished before going to
    // background (sound may have been killed by the OS while backgrounded).
    final hadPreexistingFinished =
        timers.values.any((t) => t.status == TimerStatus.finished);
    if (hadPreexistingFinished) {
      NotificationService.instance.playAlarmSound();
    }

    final hasRunning = updatedTimers.values.any(
      (t) => t.status == TimerStatus.running,
    );
    if (hasRunning) {
      ref.read(timerTickProvider.notifier).start();
    }
  }

  Future<void> _processPendingBackgroundActions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final actions = prefs.getStringList(_pendingActionsKey) ?? [];
    if (actions.isEmpty) return;

    await prefs.remove(_pendingActionsKey);

    final notifier = ref.read(activeTimerProvider.notifier);
    for (final action in actions) {
      final parts = action.split(':');
      if (parts.length < 3) continue;
      final type = parts[0];
      final recipeId = parts[1];
      final stepIndex = int.tryParse(parts[2]);
      if (stepIndex == null) continue;

      final key = '$recipeId:$stepIndex';
      switch (type) {
        case 'pause':
          notifier.pauseTimer(key);
        case 'resume':
          notifier.resumeTimer(key);
        case 'cancel':
          notifier.cancelTimer(key);
      }
    }
  }

  void _onPaused() {
    ref.read(timerTickProvider.notifier).stop();
  }
}
