import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/timer/cooking_mode_timer_duration_picker.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/recipe_timer_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

/// Öffnet den Timer-Picker als Modal Bottom Sheet.
/// Tastatur schiebt den Picker automatisch nach oben (viewInsets).
void showCookingModeTimerPicker(
  BuildContext context, {
  required String recipeId,
  required int stepIndex,
  RecipeTimer? saved,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => CookingModeTimerPickerSheet(
      recipeId: recipeId,
      stepIndex: stepIndex,
      saved: saved,
    ),
  );
}

class CookingModeTimerPickerSheet extends ConsumerStatefulWidget {
  final String recipeId;
  final int stepIndex;
  final RecipeTimer? saved;

  const CookingModeTimerPickerSheet({
    super.key,
    required this.recipeId,
    required this.stepIndex,
    this.saved,
  });

  @override
  ConsumerState<CookingModeTimerPickerSheet> createState() =>
      _CookingModeTimerPickerSheetState();
}

class _CookingModeTimerPickerSheetState
    extends ConsumerState<CookingModeTimerPickerSheet> {
  late final TextEditingController _labelController;
  late final TextEditingController _minutesController;
  late final TextEditingController _secondsController;
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
    ref.read(activeTimerProvider.notifier).startTimer(
          recipeId: widget.recipeId,
          stepIndex: widget.stepIndex,
          label: input.name ?? 'Schritt ${widget.stepIndex + 1}',
          durationSeconds: input.totalSeconds,
        );
    Navigator.pop(context);
  }

  Future<void> _onSavePressed() async {
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
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Timer konnte nicht gespeichert werden')),
        );
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Schiebt den Picker über die Tastatur
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: CookingModeTimerDurationPicker(
        labelController: _labelController,
        minutesController: _minutesController,
        secondsController: _secondsController,
        onStart: _onStartPressed,
        onCancel: () => Navigator.pop(context),
        onSave: _onSavePressed,
      ),
    );
  }
}
