import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/utils/time_formatter.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/timer/cooking_mode_timer_duration_picker.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/recipe_timer_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

class CookingModeIdleTimer extends ConsumerStatefulWidget {
  final String recipeId;
  final int stepIndex;
  final bool forceShowPicker;
  final VoidCallback? onPickerClosed;
  final RecipeTimer? saved;
  const CookingModeIdleTimer({
    super.key,
    required this.recipeId,
    required this.stepIndex,
    required this.forceShowPicker,
    this.saved,
    this.onPickerClosed,
  });

  @override
  ConsumerState<CookingModeIdleTimer> createState() =>
      _CookingModeIdleTimerState();
}

class _CookingModeIdleTimerState extends ConsumerState<CookingModeIdleTimer> {
  bool _isSettingDuration = false;
  late TextEditingController _labelController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    _labelController =
        TextEditingController(text: widget.saved?.timerName ?? '');
    final duration = widget.saved?.durationSeconds ?? 0;
    _minutesController = TextEditingController(
        text: duration > 0 ? (duration ~/ 60).toString() : '');
    _secondsController = TextEditingController(
        text: duration > 0 ? (duration % 60).toString() : '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSettingDuration || widget.forceShowPicker) {
      return CookingModeTimerDurationPicker(
        labelController: _labelController,
        minutesController: _minutesController,
        secondsController: _secondsController,
        onStart: _onStartPressed,
        onCancel: _onCancelPicker,
        onSave: _onSavePressed,
      );
    }

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
          onPressed: () => setState(() => _isSettingDuration = true),
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: greyAlpha,
          tooltip: 'Ändern',
        ),
        IconButton(
          onPressed: () => _confirmDeleteTimer(),
          icon: const Icon(Icons.delete_outline, size: 20),
          color: colorScheme.error,
          tooltip: 'Löschen',
        ),
      ],
    );
  }

  ({int totalSeconds, String? name})? _parseInput() {
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    final totalSeconds = (minutes * 60) + seconds;
    if (totalSeconds <= 0) return null;
    final name = _labelController.text.trim();
    return (totalSeconds: totalSeconds, name: name.isNotEmpty ? name : null);
  }

  void _onStartPressed() {
    final input = _parseInput();
    if (input == null) return;
    _startWithDuration(input.totalSeconds, input.name);
    _onCancelPicker();
  }

  void _onSavePressed() async {
    final input = _parseInput();
    if (input == null) return;
    try {
      final repo = ref.read(recipeRepositoryProvider);
      await repo.upsertTimer(RecipeTimer(
        recipeId: widget.recipeId,
        stepIndex: widget.stepIndex,
        durationSeconds: input.totalSeconds,
        timerName: input.name ?? '',
      ));
      ref.invalidate(recipeTimersProvider(widget.recipeId));
    } catch (_) {}
    _onCancelPicker();
  }

  void _onCancelPicker() {
    setState(() => _isSettingDuration = false);
    // Werte zurücksetzen auf gespeicherte Werte statt leeren
    _labelController.text = widget.saved?.timerName ?? '';
    final duration = widget.saved?.durationSeconds ?? 0;
    _minutesController.text = duration > 0 ? (duration ~/ 60).toString() : '';
    _secondsController.text = duration > 0 ? (duration % 60).toString() : '';
    widget.onPickerClosed?.call();
  }

  void _startWithDuration(int durationSeconds, String? label) {
    ref.read(activeTimerProvider.notifier).startTimer(
          recipeId: widget.recipeId,
          stepIndex: widget.stepIndex,
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
    } catch (_) {}
  }
}
