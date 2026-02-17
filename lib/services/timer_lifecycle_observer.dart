import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';

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

    // Tick neu starten falls noch laufende Timer da sind
    final hasRunning = ref.read(activeTimerProvider).values.any(
          (t) => t.status == TimerStatus.running,
        );
    if (hasRunning) {
      ref.read(timerTickProvider.notifier).start();
    }
  }

  void _onPaused() {
    // Tick stoppen – Notifications übernehmen im Hintergrund
    ref.read(timerTickProvider.notifier).stop();
  }
}
