import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';

class MealSlotsSegmentedButton extends StatelessWidget {
  final UserSettings newSettings;
  final ValueChanged<UserSettings> onSettingsChanged;

  const MealSlotsSegmentedButton({
    super.key,
    required this.newSettings,
    required this.onSettingsChanged,
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
      selected: newSettings.defaultMealSlots.toSet(),
      onSelectionChanged: (s) {
        if (s.isEmpty) return; // at least one slot must remain active
        onSettingsChanged(newSettings.copyWith(defaultMealSlots: s.toList()));
      },
    );
  }
}
