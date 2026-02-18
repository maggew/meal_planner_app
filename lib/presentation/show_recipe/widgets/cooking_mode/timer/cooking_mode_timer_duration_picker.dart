import 'package:flutter/material.dart';

class CookingModeTimerDurationPicker extends StatelessWidget {
  final int? savedDuration;
  final TextEditingController labelController;
  final TextEditingController minutesController;
  final TextEditingController secondsController;
  final VoidCallback onStart;
  final VoidCallback onCancel;
  const CookingModeTimerDurationPicker({
    super.key,
    required this.savedDuration,
    required this.labelController,
    required this.minutesController,
    required this.secondsController,
    required this.onStart,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    // if (savedDuration != null && inputMinutes == 0 && inputSeconds == 0) {
    //   inputMinutes = savedDuration ~/ 60;
    //   inputSeconds = savedDuration % 60;
    // }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timer einstellen',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: labelController,
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
                controller: minutesController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Min',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(':', style: TextStyle(fontSize: 20)),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: secondsController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Sek',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onCancel,
              child: const Text('Abbrechen'),
            ),
            const SizedBox(width: 4),
            FilledButton(
              onPressed: onStart,
              child: const Text('Start'),
            ),
          ],
        ),
      ],
    );
  }
}
