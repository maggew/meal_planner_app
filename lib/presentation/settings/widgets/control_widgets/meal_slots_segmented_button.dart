import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';

class MealSlotsSegmentedButton extends StatelessWidget {
  final GroupSettings groupSettings;
  final ValueChanged<GroupSettings> onGroupSettingsChanged;

  const MealSlotsSegmentedButton({
    super.key,
    required this.groupSettings,
    required this.onGroupSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<MealType>(
      multiSelectionEnabled: true,
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: MealType.breakfast,
          icon: Icon(Icons.wb_sunny_outlined),
        ),
        ButtonSegment(
          value: MealType.lunch,
          icon: Icon(Icons.lunch_dining),
        ),
        ButtonSegment(
          value: MealType.dinner,
          icon: Icon(Icons.nights_stay_outlined),
        ),
      ],
      selected: groupSettings.defaultMealSlots.toSet(),
      onSelectionChanged: (s) {
        if (s.isEmpty) return;
        onGroupSettingsChanged(
            groupSettings.copyWith(defaultMealSlots: s.toList()));
      },
    );
  }
}
