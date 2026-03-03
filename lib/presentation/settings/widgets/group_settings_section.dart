import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/settings/widgets/category_management_section.dart';
import 'package:meal_planner/presentation/settings/widgets/control_widgets/meal_slots_segmented_button.dart';
import 'package:meal_planner/presentation/settings/widgets/control_widgets/week_start_day_segmented_button.dart';
import 'package:meal_planner/presentation/settings/widgets/settings_row_widget.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/user/group_settings_provider.dart';

class GroupSettingsSection extends ConsumerWidget {
  const GroupSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupSettings = ref.watch(groupSettingsProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Gruppen-Einstellungen',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!isOnline) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.cloud_off_outlined,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ],
        ),
        if (!isOnline) ...[
          const SizedBox(height: 4),
          Text(
            'Gruppen-Einstellungen können nur online bearbeitet werden.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
        const SizedBox(height: 12),
        IgnorePointer(
          ignoring: !isOnline,
          child: Opacity(
            opacity: isOnline ? 1.0 : 0.4,
            child: Column(
              children: [
                SettingsRowWidget(
                  label: 'Wochenstart',
                  controlWidget: WeekStartDaySegmentedButton(
                    groupSettings: groupSettings,
                    onGroupSettingsChanged: (updated) =>
                        ref.read(groupSettingsProvider.notifier).update(updated),
                  ),
                ),
                SettingsRowWidget(
                  label: 'Mahlzeiten',
                  controlWidget: MealSlotsSegmentedButton(
                    groupSettings: groupSettings,
                    onGroupSettingsChanged: (updated) =>
                        ref.read(groupSettingsProvider.notifier).update(updated),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const CategoryManagementSection(),
      ],
    );
  }
}
