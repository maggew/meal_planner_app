import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/services/notification_service.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer_notification_controller.g.dart';

@Riverpod(keepAlive: true)
void timerNotificationController(Ref ref) {
  ref.listen<Map<String, ActiveTimer>>(
    activeTimerProvider,
    _renderTimerNotifications,
    fireImmediately: true,
  );
}

void _renderTimerNotifications(
  Map<String, ActiveTimer>? previous,
  Map<String, ActiveTimer> next,
) {
  final service = NotificationService.instance;

  final nextActive = Map.fromEntries(
    next.entries.where(
      (e) =>
          e.value.status == TimerStatus.running ||
          e.value.status == TimerStatus.paused,
    ),
  );

  final prevActive = previous == null
      ? <String, ActiveTimer>{}
      : Map.fromEntries(
          previous.entries.where(
            (e) =>
                e.value.status == TimerStatus.running ||
                e.value.status == TimerStatus.paused,
          ),
        );

  // Cancel child notifications for timers that became inactive (finished or removed)
  for (final key in prevActive.keys) {
    if (!nextActive.containsKey(key)) {
      service.cancelTimerChildNotification(key);
    }
  }

  if (nextActive.isEmpty) {
    if (prevActive.isNotEmpty) {
      service.cancelSummaryNotification();
    }
    return;
  }

  // Show/update all active child notifications
  for (final entry in nextActive.entries) {
    final t = entry.value;
    service.showTimerChildNotification(
      key: entry.key,
      recipeTitle: t.recipeTitle,
      label: t.label,
      isPaused: t.status == TimerStatus.paused,
      endTime: t.endTime,
      pausedRemainingSeconds: t.pausedRemainingSeconds,
    );
  }

  // Update summary notification
  final runningWithEndTime = nextActive.values
      .where((t) => t.status == TimerStatus.running && t.endTime != null)
      .toList();

  final nearestEndTime = runningWithEndTime.isEmpty
      ? null
      : runningWithEndTime
          .map((t) => t.endTime!)
          .reduce((a, b) => a.isBefore(b) ? a : b);

  service.showSummaryNotification(
    timerCount: nextActive.length,
    nearestEndTime: nearestEndTime,
  );
}
