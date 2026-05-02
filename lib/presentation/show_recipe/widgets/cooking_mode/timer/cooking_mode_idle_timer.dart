import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/utils/time_formatter.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/timer/cooking_mode_timer_picker_sheet.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/recipe_timer_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

class CookingModeIdleTimer extends ConsumerStatefulWidget {
  final String recipeId;
  final String recipeTitle;
  final int stepIndex;
  final RecipeTimer? saved;

  const CookingModeIdleTimer({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
    required this.stepIndex,
    this.saved,
  });

  @override
  ConsumerState<CookingModeIdleTimer> createState() =>
      _CookingModeIdleTimerState();
}

class _CookingModeIdleTimerState extends ConsumerState<CookingModeIdleTimer> {
  @override
  Widget build(BuildContext context) {
    if (widget.saved == null) return const SizedBox.shrink();
    final RecipeTimer saved = widget.saved!;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool timerNameIsNotEmpty = saved.timerName.isNotEmpty;
    final Color greyAlpha = colorScheme.onSurface.withValues(alpha: 0.5);

    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 20, color: greyAlpha),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (timerNameIsNotEmpty)
                Text(
                  saved.timerName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              Text(formatSeconds(saved.durationSeconds),
                  style: (timerNameIsNotEmpty
                          ? textTheme.bodySmall
                          : textTheme.bodyMedium)
                      ?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: timerNameIsNotEmpty ? greyAlpha : null,
                  )),
            ],
          ),
        ),
        TextButton(
          onPressed: () => ref.read(activeTimerProvider.notifier).startTimer(
                recipeId: widget.recipeId,
                stepIndex: widget.stepIndex,
                recipeTitle: widget.recipeTitle,
                label: widget.saved?.timerName ??
                    'Schritt ${widget.stepIndex + 1}',
                durationSeconds: 60,
                savedDurationSeconds: widget.saved?.durationSeconds,
              ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('+1 Min'),
        ),
        IconButton(
          onPressed: () => _startWithDuration(
            saved.durationSeconds,
            saved.timerName.isNotEmpty ? saved.timerName : null,
          ),
          icon: const Icon(Icons.play_arrow_rounded),
          color: colorScheme.primary,
          tooltip: 'Start',
        ),
        IconButton(
          onPressed: () => showCookingModeTimerPicker(
            context,
            recipeId: widget.recipeId,
            recipeTitle: widget.recipeTitle,
            stepIndex: widget.stepIndex,
            saved: widget.saved,
          ),
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: greyAlpha,
          tooltip: 'Ändern',
        ),
        IconButton(
          onPressed: () => _confirmDeleteTimer(),
          icon: const Icon(Icons.delete_outline, size: 20),
          color: greyAlpha,
          tooltip: 'Löschen',
        ),
      ],
    );
  }

  void _startWithDuration(int durationSeconds, String? label) {
    ref.read(activeTimerProvider.notifier).startTimer(
          recipeId: widget.recipeId,
          stepIndex: widget.stepIndex,
          recipeTitle: widget.recipeTitle,
          label: label ?? 'Schritt ${widget.stepIndex + 1}',
          durationSeconds: durationSeconds,
        );
  }

  void _confirmDeleteTimer() {
    final saved = ref
        .read(recipeTimersProvider(widget.recipeId))
        .value?[widget.stepIndex];
    final name = saved?.timerName.isNotEmpty == true
        ? saved!.timerName
        : 'Schritt ${widget.stepIndex + 1}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer löschen?'),
        content: Text('Timer "$name" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => context.router.pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              context.router.pop();
              _deleteTimer();
            },
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _deleteTimer() async {
    try {
      final repo = ref.read(recipeRepositoryProvider);
      await repo.deleteTimer(widget.recipeId, widget.stepIndex);
      ref.invalidate(recipeTimersProvider(widget.recipeId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Timer konnte nicht gelöscht werden')),
        );
      }
    }
  }
}
