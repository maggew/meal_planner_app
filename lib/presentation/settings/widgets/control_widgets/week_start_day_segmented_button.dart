import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/enums/week_start_day.dart';

class WeekStartDaySegmentedButton extends StatelessWidget {
  final UserSettings newSettings;
  final ValueChanged<UserSettings> onSettingsChanged;

  const WeekStartDaySegmentedButton({
    super.key,
    required this.newSettings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<WeekStartDay>(
      segments: const [
        ButtonSegment(value: WeekStartDay.monday, label: Text('Montag')),
        ButtonSegment(value: WeekStartDay.sunday, label: Text('Sonntag')),
      ],
      showSelectedIcon: false,
      selected: {newSettings.weekStartDay},
      onSelectionChanged: (s) =>
          onSettingsChanged(newSettings.copyWith(weekStartDay: s.first)),
    );
  }
}
