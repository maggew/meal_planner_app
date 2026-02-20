import 'package:flutter/material.dart';

class CookingModeTimerDurationPicker extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color inputBorderColor = colorScheme.onSurface.withValues(alpha: 0.3);

    final ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
      side: BorderSide(color: inputBorderColor),
      foregroundColor: colorScheme.onSurface,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          'Timer einstellen',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        TextField(
          controller: labelController,
          decoration: InputDecoration(
              labelText: 'Name (optional)',
              hintText: 'z.B. Nudeln kochen',
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                color: inputBorderColor,
              ))),
        ),
        Row(
          children: [
            SizedBox(
              width: 60,
              child: TextField(
                controller: minutesController,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(':', style: textTheme.bodyLarge),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: secondsController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    labelText: 'Sek',
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: inputBorderColor,
                    ))),
              ),
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: outlineButtonStyle,
                child: const Text('Abbrechen', overflow: TextOverflow.ellipsis),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                onPressed: onSave,
                style: outlineButtonStyle,
                child: const Text(
                  'Speichern',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 80, maxWidth: 100),
              child: FilledButton(
                onPressed: onStart,
                child: const Text('Start'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
