import 'dart:async';
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
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
