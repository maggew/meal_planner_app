import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/enums/tab_position.dart';
import 'package:meal_planner/presentation/settings/widgets/account_section.dart';
import 'package:meal_planner/presentation/settings/widgets/category_management_section.dart';
import 'package:meal_planner/presentation/settings/widgets/control_widgets/meal_slots_segmented_button.dart';
import 'package:meal_planner/presentation/settings/widgets/control_widgets/theme_segmented_button.dart';
import 'package:meal_planner/presentation/settings/widgets/control_widgets/week_start_day_segmented_button.dart';
import 'package:meal_planner/presentation/settings/widgets/settings_row_widget.dart';

class SettingsBody extends StatelessWidget {
  final UserSettings settings;
  final ValueChanged<UserSettings> onSettingsChanged;
  final VoidCallback onLogout;
  const SettingsBody({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          const AccountSection(),
          const Divider(height: 32),
          SettingsRowWidget(
            label: 'Tab Position',
            controlWidget: SwitchListTile(
              title: const Text('Tabs rechts anzeigen'),
              value: settings.tabPosition == TabPosition.right,
              onChanged: (value) {
                onSettingsChanged(
                  settings.copyWith(
                    tabPosition: value ? TabPosition.right : TabPosition.left,
                  ),
                );
              },
            ),
          ),
          SettingsRowWidget(
            label: "Theme",
            controlWidget: ThemeSegmentedButton(
              newSettings: settings,
              onSettingsChanged: onSettingsChanged,
            ),
          ),
          SettingsRowWidget(
            label: 'Wochenstart',
            controlWidget: WeekStartDaySegmentedButton(
              newSettings: settings,
              onSettingsChanged: onSettingsChanged,
            ),
          ),
          SettingsRowWidget(
            label: 'Mahlzeiten',
            controlWidget: MealSlotsSegmentedButton(
              newSettings: settings,
              onSettingsChanged: onSettingsChanged,
            ),
          ),
          const Divider(height: 32),
          const CategoryManagementSection(),
          const Divider(height: 32),
          OutlinedButton(
            onPressed: onLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('Ausloggen'),
          ),
        ],
      ),
    );
  }
}
