import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';

class ThemeSegmentedButton extends StatelessWidget {
  final UserSettings newSettings;
  final ValueChanged<UserSettings> onSettingsChanged;
  const ThemeSegmentedButton({
    super.key,
    required this.newSettings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeOption>(
      segments: const [
        ButtonSegment(
          value: ThemeOption.light,
          label: Text('Hell'),
        ),
        ButtonSegment(
          value: ThemeOption.system,
          label: Text('System'),
        ),
        ButtonSegment(
          value: ThemeOption.dark,
          label: Text('Dunkel'),
        ),
      ],
      showSelectedIcon: false,
      selected: {newSettings.themeOption},
      onSelectionChanged: (selection) {
        onSettingsChanged(
          newSettings.copyWith(themeOption: selection.first),
        );
      },
    );
  }
}
