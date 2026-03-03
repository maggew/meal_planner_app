import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';
import 'package:meal_planner/domain/enums/week_start_day.dart';

class WeekStartDaySegmentedButton extends StatelessWidget {
  final GroupSettings groupSettings;
  final ValueChanged<GroupSettings> onGroupSettingsChanged;

  const WeekStartDaySegmentedButton({
    super.key,
    required this.groupSettings,
    required this.onGroupSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<WeekStartDay>(
      segments: const [
        ButtonSegment(value: WeekStartDay.monday, label: Text('Montag')),
        ButtonSegment(value: WeekStartDay.sunday, label: Text('Sonntag')),
      ],
      showSelectedIcon: false,
      selected: {groupSettings.weekStartDay},
      onSelectionChanged: (s) =>
          onGroupSettingsChanged(groupSettings.copyWith(weekStartDay: s.first)),
    );
  }
}
