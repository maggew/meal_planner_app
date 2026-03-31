import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';
import 'package:meal_planner/services/notification_service.dart';

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

  void _onResumed() {
    final timers = ref.read(activeTimerProvider);
    if (timers.isEmpty) return;

    // Abgelaufene Timer erkennen
    ref.read(activeTimerProvider.notifier).checkExpiredTimers();

    // Re-read state after checkExpiredTimers may have changed it
    final updatedTimers = ref.read(activeTimerProvider);

    // Start alarm sound if timers expired while backgrounded
    final hasFinished = updatedTimers.values.any(
      (t) => t.status == TimerStatus.finished,
    );
    if (hasFinished) {
      NotificationService.instance.playAlarmSound();
    }

    final hasActive = updatedTimers.values.any(
          (t) =>
              t.status == TimerStatus.running ||
              t.status == TimerStatus.paused,
        );

    if (hasActive) {
      // Ongoing-Notification sofort mit aktuellem Countdown aktualisieren
      ref.read(timerTickProvider.notifier).updateOngoingNotification();

      // Tick neu starten falls noch laufende Timer da sind
      if (updatedTimers.values.any(
            (t) => t.status == TimerStatus.running,
          )) {
        ref.read(timerTickProvider.notifier).start();
      }
    } else {
      // Alle Timer sind im Hintergrund abgelaufen — Ongoing-Notification aufräumen
      NotificationService.instance.cancelOngoingTimerNotification();
    }
  }

  void _onPaused() {
    // Ongoing-Notification mit Chronometer-Endzeit aktualisieren,
    // damit Android den Countdown im Hintergrund weiterzählt
    ref.read(timerTickProvider.notifier).updateOngoingNotification();
    // Tick stoppen – Android-Chronometer übernimmt im Hintergrund
    ref.read(timerTickProvider.notifier).stop();
  }
}
