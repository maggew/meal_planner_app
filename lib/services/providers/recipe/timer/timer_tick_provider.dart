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
      _updateOngoingNotification();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    NotificationService.instance.cancelOngoingTimerNotification();
  }

  void _updateOngoingNotification() {
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
      final time = formatSeconds(t.remainingSeconds);
      final status = t.status == TimerStatus.paused ? ' ⏸' : '';
      return '${t.label}: $time$status';
    }).toList();

    NotificationService.instance.showOngoingTimerNotification(lines);
  }
}
