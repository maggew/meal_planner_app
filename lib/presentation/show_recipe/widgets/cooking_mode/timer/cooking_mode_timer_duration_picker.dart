import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/presentation/common/extensions/text_theme_extensions.dart';

class CookingModeTimerDurationPicker extends StatefulWidget {
  final TextEditingController labelController;
  final TextEditingController minutesController;
  final TextEditingController secondsController;
  final VoidCallback onStart;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  const CookingModeTimerDurationPicker({
    super.key,
    required this.labelController,
    required this.minutesController,
    required this.secondsController,
    required this.onStart,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<CookingModeTimerDurationPicker> createState() =>
      _CookingModeTimerDurationPickerState();
}

class _CookingModeTimerDurationPickerState
    extends State<CookingModeTimerDurationPicker> {
  String? _secondsError;

  @override
  void initState() {
    super.initState();
    _secondsError = _validateSeconds(widget.secondsController.text);
    widget.secondsController.addListener(_onSecondsChanged);
  }

  @override
  void dispose() {
    widget.secondsController.removeListener(_onSecondsChanged);
    super.dispose();
  }

  void _onSecondsChanged() {
    setState(() {
      _secondsError = _validateSeconds(widget.secondsController.text);
    });
  }

  String? _validateSeconds(String text) {
    final val = int.tryParse(text);
    if (val != null && val > 59) return 'Max. 59';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color inputBorderColor = colorScheme.onSurface.withValues(alpha: 0.3);

    final ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
      side: BorderSide(color: inputBorderColor),
      foregroundColor: colorScheme.onSurface,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          'Timer einstellen',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        TextField(
          controller: widget.labelController,
          autofocus: true,
          decoration: InputDecoration(
              labelText: 'Name (optional)',
              hintText: 'z.B. Nudeln kochen',
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                color: inputBorderColor,
              ))),
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        Row(
          children: [
            Flexible(
              child: SizedBox(
                width: 60,
                child: TextField(
                  controller: widget.minutesController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      labelText: 'Min',
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: inputBorderColor,
                      ))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(':', style: textTheme.bodyLarge),
            ),
            Flexible(
              child: SizedBox(
                width: 60,
                child: TextField(
                  controller: widget.secondsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      labelText: 'Sek',
                      errorText: _secondsError,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: inputBorderColor,
                      ))),
                ),
              ),
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onCancel,
                style: outlineButtonStyle,
                child: Text(
                  'Abbrechen',
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMediumEmphasis
                      ?.copyWith(color: colorScheme.onSurface),
                ),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onSave,
                style: outlineButtonStyle,
                child: Text(
                  'Speichern',
                  style: textTheme.bodyMediumEmphasis
                      ?.copyWith(color: colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 80, maxWidth: 100),
              child: FilledButton(
                onPressed: widget.onStart,
                child: Text('Start',
                    style: textTheme.bodyMediumEmphasis
                        ?.copyWith(color: colorScheme.onPrimary)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
