import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/enums/tab_position.dart';
import 'package:meal_planner/presentation/settings/widgets/control_widgets/theme_segmented_button.dart';
import 'package:meal_planner/presentation/settings/widgets/settings_row_widget.dart';

class SettingsBody extends StatelessWidget {
  final UserSettings newSettings;
  final ValueChanged<UserSettings> onSettingsChanged;
  const SettingsBody({
    super.key,
    required this.newSettings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          SettingsRowWidget(
            label: 'Tab Position',
            controlWidget: SwitchListTile(
              title: const Text('Tabs rechts anzeigen'),
              value: newSettings.tabPosition == TabPosition.right,
              onChanged: (value) {
                onSettingsChanged(
                  newSettings.copyWith(
                    tabPosition: value ? TabPosition.right : TabPosition.left,
                  ),
                );
              },
            ),
          ),
          SettingsRowWidget(
              label: "Theme",
              controlWidget: ThemeSegmentedButton(
                newSettings: newSettings,
                onSettingsChanged: onSettingsChanged,
              )),
        ],
      ),
    );
  }
}
