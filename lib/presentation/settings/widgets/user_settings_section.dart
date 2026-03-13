import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/enums/tab_position.dart';
import 'package:meal_planner/presentation/settings/widgets/control_widgets/theme_segmented_button.dart';
import 'package:meal_planner/presentation/settings/widgets/settings_row_widget.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';

class UserSettingsSection extends ConsumerWidget {
  const UserSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Persönliche Einstellungen',
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SettingsRowWidget(
          label: 'Tab Position',
          controlWidget: SwitchListTile(
            title: const Text('Tabs rechts anzeigen'),
            value: settings.tabPosition == TabPosition.right,
            onChanged: (value) {
              ref.read(userSettingsProvider.notifier).update(
                    settings.copyWith(
                      tabPosition:
                          value ? TabPosition.right : TabPosition.left,
                    ),
                  );
            },
          ),
        ),
        SettingsRowWidget(
          label: 'Theme',
          controlWidget: ThemeSegmentedButton(
            newSettings: settings,
            onSettingsChanged: (updated) =>
                ref.read(userSettingsProvider.notifier).update(updated),
          ),
        ),
      ],
    );
  }
}
