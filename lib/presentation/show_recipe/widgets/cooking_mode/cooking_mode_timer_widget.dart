import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/recipe_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

class CookingModeTimerWidget extends ConsumerStatefulWidget {
  final String recipeId;
  final int stepIndex;
  final double pageMargin;
  final double borderRadius;
  final bool forceShowPicker;
  final VoidCallback? onPickerClosed;

  const CookingModeTimerWidget({
    super.key,
    required this.recipeId,
    required this.stepIndex,
    required this.pageMargin,
    required this.borderRadius,
    this.forceShowPicker = false,
    this.onPickerClosed,
  });

  @override
  ConsumerState<CookingModeTimerWidget> createState() =>
      _CookingModeTimerWidgetState();
}

class _CookingModeTimerWidgetState extends ConsumerState<CookingModeTimerWidget>
    with SingleTickerProviderStateMixin {
  int _inputMinutes = 0;
  int _inputSeconds = 0;
  bool _isSettingDuration = false;
  bool _isEditingLabel = false;
  late TextEditingController _labelController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _labelController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String get _timerKey => '${widget.recipeId}:${widget.stepIndex}';

  @override
  Widget build(BuildContext context) {
    // Tick watchen für sekündliche UI-Updates
    ref.watch(timerTickProvider);

    final activeTimers = ref.watch(activeTimerProvider);
    final activeTimer = activeTimers[_timerKey];
    final savedTimers = ref.watch(recipeTimersProvider(widget.recipeId));

    // Pulse-Animation steuern
    if (activeTimer?.status == TimerStatus.finished) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.reset();
    }

    final hasSaved = savedTimers.value?[widget.stepIndex] != null;
    if (activeTimer == null &&
        !hasSaved &&
        !widget.forceShowPicker &&
        !_isSettingDuration) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final isFinished = activeTimer?.status == TimerStatus.finished;
        final pulseValue = _pulseController.value;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: widget.pageMargin),
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isFinished
                ? Color.lerp(Colors.white, Colors.green[50], pulseValue)
                : Colors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: isFinished
                ? Border.all(
                    color: Colors.green
                        .withValues(alpha: 0.3 + (pulseValue * 0.4)),
                    width: 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: isFinished
                    ? Colors.green.withValues(alpha: 0.15 + (pulseValue * 0.15))
                    : Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 0.0,
                offset: const Offset(5.0, 5.0),
              ),
            ],
          ),
          child: child,
        );
      },
      child: activeTimer != null
          ? _buildActiveTimer(activeTimer)
          : _buildIdleTimer(savedTimers),
    );
  }
  // ==================== IDLE STATE ====================

  Widget _buildIdleTimer(AsyncValue<Map<int, dynamic>> savedTimers) {
    final saved = savedTimers.value![widget.stepIndex];

    if (_isSettingDuration || widget.forceShowPicker) {
      return _buildDurationPicker(savedDuration: saved?.durationSeconds);
    }

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
                _formatSeconds(saved.durationSeconds),
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

  // ==================== DURATION PICKER ====================

  Widget _buildDurationPicker({int? savedDuration}) {
    if (savedDuration != null && _inputMinutes == 0 && _inputSeconds == 0) {
      _inputMinutes = savedDuration ~/ 60;
      _inputSeconds = savedDuration % 60;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timer einstellen',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _labelController,
          decoration: const InputDecoration(
            labelText: 'Name (optional)',
            hintText: 'z.B. Nudeln kochen',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 60,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Min',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                controller: TextEditingController(
                  text: _inputMinutes > 0 ? '$_inputMinutes' : '',
                ),
                onChanged: (v) => _inputMinutes = int.tryParse(v) ?? 0,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(':', style: TextStyle(fontSize: 20)),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Sek',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                controller: TextEditingController(
                  text: _inputSeconds > 0 ? '$_inputSeconds' : '',
                ),
                onChanged: (v) => _inputSeconds = int.tryParse(v) ?? 0,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() {
                _isSettingDuration = false;
                _inputMinutes = 0;
                _inputSeconds = 0;
                _labelController.clear();
                widget.onPickerClosed?.call();
              }),
              child: const Text('Abbrechen'),
            ),
            const SizedBox(width: 4),
            FilledButton(
              onPressed: _onStartPressed,
              child: const Text('Start'),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== ACTIVE TIMER ====================

  Widget _buildActiveTimer(ActiveTimer timer) {
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
                  : _formatSeconds(timer.remainingSeconds),
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
                onPressed: () => ref
                    .read(activeTimerProvider.notifier)
                    .pauseTimer(_timerKey),
                icon: const Icon(Icons.pause, size: 18),
                label: const Text('Pause'),
              ),
            ],
            if (timer.status == TimerStatus.paused) ...[
              TextButton.icon(
                onPressed: () => ref
                    .read(activeTimerProvider.notifier)
                    .resumeTimer(_timerKey),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Weiter'),
              ),
            ],
            if (timer.status == TimerStatus.finished) ...[
              TextButton.icon(
                onPressed: () => ref
                    .read(activeTimerProvider.notifier)
                    .dismissFinished(_timerKey),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Fertig'),
              ),
            ],
            if (timer.status != TimerStatus.finished) ...[
              TextButton.icon(
                onPressed: () => ref
                    .read(activeTimerProvider.notifier)
                    .cancelTimer(_timerKey),
                icon: const Icon(Icons.stop, size: 18),
                label: const Text('Stopp'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ==================== HELPERS ====================

  void _onStartPressed() {
    final totalSeconds = (_inputMinutes * 60) + _inputSeconds;
    if (totalSeconds <= 0) return;

    final name = _labelController.text.trim();

    _startWithDuration(totalSeconds, name.isNotEmpty ? name : null);
    setState(() {
      _isSettingDuration = false;
      _inputMinutes = 0;
      _inputSeconds = 0;
      _labelController.clear();
    });
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

  String _formatSeconds(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _saveLabel() {
    final newLabel = _labelController.text.trim();
    if (newLabel.isNotEmpty) {
      ref.read(activeTimerProvider.notifier).updateLabel(
            _timerKey,
            newLabel,
          );
    }
    setState(() => _isEditingLabel = false);
  }
}
