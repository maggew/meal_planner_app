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
            icon: Icon(Icons.light_mode)),
        ButtonSegment(
            value: ThemeOption.system,
            label: Text('System'),
            icon: Icon(Icons.settings_brightness)),
        ButtonSegment(
            value: ThemeOption.dark,
            label: Text('Dunkel'),
            icon: Icon(Icons.dark_mode)),
      ],
      selected: {newSettings.themeOption},
      onSelectionChanged: (selection) {
        onSettingsChanged(
          newSettings.copyWith(themeOption: selection.first),
        );
      },
    );
  }
}
