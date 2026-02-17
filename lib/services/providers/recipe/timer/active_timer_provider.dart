import 'dart:async';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/services/notification_service.dart';
import 'package:meal_planner/services/providers/recipe/timer/recipe_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_timer_provider.g.dart';

@Riverpod(keepAlive: true)
class ActiveTimerNotifier extends _$ActiveTimerNotifier {
  int _nextNotificationId = 0;

  @override
  Map<String, ActiveTimer> build() {
    return {};
  }

  void startTimer({
    required String recipeId,
    required int stepIndex,
    required String label,
    required int durationSeconds,
    int? savedDurationSeconds,
  }) {
    final key = '$recipeId:$stepIndex';

    // savedDurationSeconds: beim ersten Start = durationSeconds,
    // bei "+X Min" = alter DB-Wert aus bestehendem Timer
    final existing = state[key];
    final dbDuration = savedDurationSeconds ??
        existing?.savedDurationSeconds ??
        durationSeconds;

    final timer = ActiveTimer(
      recipeId: recipeId,
      stepIndex: stepIndex,
      label: label,
      totalSeconds: durationSeconds,
      savedDurationSeconds: dbDuration,
      endTime: DateTime.now().add(Duration(seconds: durationSeconds)),
      notificationId: _nextNotificationId++,
      status: TimerStatus.running,
    );

    state = {...state, key: timer};

    // Nur beim ersten Start persistieren
    if (savedDurationSeconds == null && existing == null) {
      _persistTimer(timer);
    }

    ref.read(timerTickProvider.notifier).start();
    NotificationService.instance.scheduleNotification(
      id: timer.notificationId,
      title: 'Timer abgelaufen',
      body: timer.label,
      scheduledTime: timer.endTime!,
    );
  }

  void pauseTimer(String key) {
    final timer = state[key];
    if (timer == null || timer.status != TimerStatus.running) return;

    final remaining = timer.remainingSeconds;
    state = {
      ...state,
      key: timer.copyWith(
        status: TimerStatus.paused,
        pausedRemainingSeconds: remaining,
        endTime: null,
      ),
    };
    NotificationService.instance.cancelNotification(timer.notificationId);
  }

  void resumeTimer(String key) {
    final timer = state[key];
    if (timer == null || timer.status != TimerStatus.paused) return;

    final remaining = timer.pausedRemainingSeconds ?? 0;
    if (remaining <= 0) return;

    final newEndTime = DateTime.now().add(Duration(seconds: remaining));

    state = {
      ...state,
      key: timer.copyWith(
        status: TimerStatus.running,
        endTime: newEndTime,
        pausedRemainingSeconds: null,
      ),
    };

    ref.read(timerTickProvider.notifier).start();
    NotificationService.instance.scheduleNotification(
      id: timer.notificationId,
      title: 'Timer abgelaufen',
      body: timer.label,
      scheduledTime: newEndTime,
    );
  }

  void cancelTimer(String key) {
    final timer = state[key];
    if (timer != null) {
      NotificationService.instance.cancelNotification(timer.notificationId);
    }
    final newState = Map<String, ActiveTimer>.from(state);
    newState.remove(key);
    state = newState;
    _stopTickIfNoActiveTimers();
  }

  void markAsFinished(String key) {
    final timer = state[key];
    if (timer == null) return;

    state = {
      ...state,
      key: timer.copyWith(
        status: TimerStatus.finished,
        endTime: null,
      ),
    };
    NotificationService.instance.cancelNotification(timer.notificationId);
  }

  void dismissFinished(String key) {
    final newState = Map<String, ActiveTimer>.from(state);
    newState.remove(key);
    state = newState;

    final hasFinished = state.values.any(
      (t) => t.status == TimerStatus.finished,
    );
    if (!hasFinished) {
      NotificationService.instance.stopAlarmSound();
    }
    _stopTickIfNoActiveTimers();
  }

  void _stopTickIfNoActiveTimers() {
    final hasActive = state.values.any(
      (t) => t.status == TimerStatus.running || t.status == TimerStatus.paused,
    );
    if (!hasActive) {
      ref.read(timerTickProvider.notifier).stop();
    }
  }

  void updateLabel(String key, String newLabel) {
    final timer = state[key];
    if (timer == null) return;

    state = {
      ...state,
      key: timer.copyWith(label: newLabel),
    };

    // Name in DB persistieren (fire & forget)
    _persistTimer(timer.copyWith(label: newLabel));
  }

  /// Alle laufenden Timer prüfen (wird vom Tick aufgerufen)
  void checkExpiredTimers() {
    final updates = <String, ActiveTimer>{};
    for (final entry in state.entries) {
      if (entry.value.isExpired) {
        updates[entry.key] = entry.value.copyWith(
          status: TimerStatus.finished,
          endTime: null,
        );
      }
    }
    if (updates.isNotEmpty) {
      state = {...state, ...updates};
      NotificationService.instance.playAlarmSound();
    }
  }

  Future<void> _persistTimer(ActiveTimer timer) async {
    try {
      final repo = ref.read(recipeRepositoryProvider);
      await repo.upsertTimer(RecipeTimer(
        recipeId: timer.recipeId,
        stepIndex: timer.stepIndex,
        timerName: timer.label,
        durationSeconds: timer.savedDurationSeconds,
      ));
      ref.invalidate(recipeTimersProvider(timer.recipeId));
    } catch (_) {}
  }
}
