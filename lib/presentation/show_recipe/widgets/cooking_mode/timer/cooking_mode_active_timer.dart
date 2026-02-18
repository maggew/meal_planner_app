import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/utils/time_formatter.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';

class CookingModeActiveTimer extends ConsumerWidget {
  final ActiveTimer timer;
  final String timerKey;
  const CookingModeActiveTimer({
    super.key,
    required this.timer,
    required this.timerKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Countdown + Label
        Row(
          children: [
            Icon(
              timer.status == TimerStatus.finished
                  ? Icons.check_circle
                  : Icons.timer,
              color: timer.status == TimerStatus.finished
                  ? Colors.green
                  : Colors.deepOrange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                timer.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              timer.status == TimerStatus.finished
                  ? 'Fertig!'
                  : formatSeconds(timer.remainingSeconds),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: timer.status == TimerStatus.finished
                    ? Colors.green
                    : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: timer.progress,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              timer.status == TimerStatus.finished
                  ? Colors.green
                  : Colors.deepOrange,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (timer.status == TimerStatus.running) ...[
              TextButton.icon(
                onPressed: () =>
                    ref.read(activeTimerProvider.notifier).pauseTimer(timerKey),
                icon: const Icon(Icons.pause, size: 18),
                label: const Text('Pause'),
              ),
            ],
            if (timer.status == TimerStatus.paused) ...[
              TextButton.icon(
                onPressed: () => ref
                    .read(activeTimerProvider.notifier)
                    .resumeTimer(timerKey),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Weiter'),
              ),
            ],
            if (timer.status == TimerStatus.finished) ...[
              TextButton.icon(
                onPressed: () => ref
                    .read(activeTimerProvider.notifier)
                    .dismissFinished(timerKey),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Fertig'),
              ),
            ],
            if (timer.status != TimerStatus.finished) ...[
              TextButton.icon(
                onPressed: () => ref
                    .read(activeTimerProvider.notifier)
                    .cancelTimer(timerKey),
                icon: const Icon(Icons.stop, size: 18),
                label: const Text('Stopp'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
