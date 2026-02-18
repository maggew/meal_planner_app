import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/utils/time_formatter.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/timer/cooking_mode_timer_duration_picker.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/recipe_timer_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

class CookingModeIdleTimer extends ConsumerStatefulWidget {
  //final AsyncValue<Map<int, dynamic>> savedTimers;
  //final bool isSettingDuration;
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
    //required this.savedTimers,
    //required this.isSettingDuration,
    // required this.inputMinutes,
    // required this.inputSeconds,
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
    _labelController = TextEditingController();
    _minutesController = TextEditingController();
    _secondsController = TextEditingController();
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
        savedDuration: widget.saved?.durationSeconds,
        labelController: _labelController,
        minutesController: _minutesController,
        secondsController: _secondsController,
        onStart: _onStartPressed,
        onCancel: _onCancelPicker,
      );
    }

    final RecipeTimer saved = widget.saved!;

    return Row(
      children: [
        const Icon(Icons.timer_outlined, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (saved.timerName.isNotEmpty)
                Text(
                  saved.timerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                formatSeconds(saved.durationSeconds),
                style: TextStyle(
                  fontSize: saved.timerName.isNotEmpty ? 13 : 16,
                  fontWeight: FontWeight.w600,
                  color:
                      saved.timerName.isNotEmpty ? Colors.grey : Colors.black,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _startWithDuration(
            saved.durationSeconds,
            saved.timerName.isNotEmpty ? saved.timerName : null,
          ),
          icon: const Icon(Icons.play_arrow_rounded),
          color: Colors.deepOrange,
          tooltip: 'Start',
        ),
        IconButton(
          onPressed: () => setState(() => _isSettingDuration = true),
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: Colors.grey,
          tooltip: 'Ändern',
        ),
        IconButton(
          onPressed: () => _confirmDeleteTimer(),
          icon: const Icon(Icons.delete_outline, size: 20),
          color: Colors.red[300],
          tooltip: 'Löschen',
        ),
      ],
    );
  }

  void _onStartPressed() {
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    final totalSeconds = (minutes * 60) + seconds;
    if (totalSeconds <= 0) return;

    final name = _labelController.text.trim();
    _startWithDuration(totalSeconds, name.isNotEmpty ? name : null);
    _onCancelPicker();
  }

  void _onCancelPicker() {
    setState(() => _isSettingDuration = false);
    _minutesController.clear();
    _secondsController.clear();
    _labelController.clear();
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTimer();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
