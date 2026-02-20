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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final isFinished = timer.status == TimerStatus.finished;
    final isRunning = timer.status == TimerStatus.running;
    final isPaused = timer.status == TimerStatus.paused;
    return Column(
      children: [
        // Countdown + Label
        Row(
          children: [
            Icon(
              isFinished ? Icons.check_circle : Icons.timer,
              color: isFinished ? colorScheme.primary : colorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                timer.label,
                style:
                    textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              isFinished ? 'Fertig!' : formatSeconds(timer.remainingSeconds),
              style: textTheme.displayMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
                color: isFinished ? colorScheme.primary : colorScheme.onSurface,
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
            backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              isFinished ? colorScheme.primary : colorScheme.secondary,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isRunning) ...[
              TextButton.icon(
                onPressed: () =>
                    ref.read(activeTimerProvider.notifier).pauseTimer(timerKey),
                icon: const Icon(Icons.pause, size: 18),
                label: const Text('Pause'),
              ),
            ],
            if (isPaused) ...[
              TextButton.icon(
                onPressed: () => ref
                    .read(activeTimerProvider.notifier)
                    .resumeTimer(timerKey),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Weiter'),
              ),
            ],
            if (isFinished) ...[
              TextButton.icon(
                onPressed: () => ref
                    .read(activeTimerProvider.notifier)
                    .dismissFinished(timerKey),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Fertig'),
              ),
            ],
            if (!isFinished) ...[
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
