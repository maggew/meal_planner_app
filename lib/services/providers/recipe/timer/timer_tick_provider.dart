import 'dart:async';
import 'package:meal_planner/core/utils/time_formatter.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/services/notification_service.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer_tick_provider.g.dart';

@Riverpod(keepAlive: true)
class TimerTick extends _$TimerTick {
  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    return 0;
  }

  void start() {
    if (_timer?.isActive ?? false) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state++;
      ref.read(activeTimerProvider.notifier).checkExpiredTimers();
      updateOngoingNotification();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    // Ongoing-Notification NICHT hier canceln — sie soll im Hintergrund
    // sichtbar bleiben solange Timer laufen. Canceln übernimmt
    // _stopTickIfNoActiveTimers() sobald keine aktiven Timer mehr existieren.
  }

  void cancelOngoingNotification() {
    NotificationService.instance.cancelOngoingTimerNotification();
  }

  void updateOngoingNotification() {
    final timers = ref.read(activeTimerProvider);
    final running = timers.values
        .where((t) =>
            t.status == TimerStatus.running || t.status == TimerStatus.paused)
        .toList();

    if (running.isEmpty) {
      NotificationService.instance.cancelOngoingTimerNotification();
      return;
    }

    final lines = running.map((t) {
      if (t.status == TimerStatus.paused) {
        return '${t.label}: ${formatSeconds(t.remainingSeconds)} ⏸';
      }
      return t.label;
    }).toList();

    // Nächste Endzeit für den Android-Chronometer-Countdown
    final runningTimers =
        running.where((t) => t.status == TimerStatus.running && t.endTime != null);
    final nearestEndTime = runningTimers.isEmpty
        ? null
        : runningTimers.map((t) => t.endTime!).reduce((a, b) => a.isBefore(b) ? a : b);

    NotificationService.instance.showOngoingTimerNotification(
      lines,
      nearestEndTime: nearestEndTime,
    );
  }
}
