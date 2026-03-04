import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/presentation/settings/widgets/category_management_section.dart';
import 'package:meal_planner/presentation/settings/widgets/control_widgets/meal_slots_segmented_button.dart';
import 'package:meal_planner/presentation/settings/widgets/control_widgets/week_start_day_segmented_button.dart';
import 'package:meal_planner/presentation/settings/widgets/settings_row_widget.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/user/group_settings_provider.dart';

class GroupSettingsSection extends ConsumerStatefulWidget {
  const GroupSettingsSection({super.key});

  @override
  ConsumerState<GroupSettingsSection> createState() =>
      _GroupSettingsSectionState();
}

class _GroupSettingsSectionState extends ConsumerState<GroupSettingsSection> {
  bool _weekStartLoading = false;
  bool _mealSlotsLoading = false;

  Future<void> _updateSetting({
    required GroupSettings updated,
    required void Function(bool) setLoading,
  }) async {
    setState(() => setLoading(true));
    try {
      await ref.read(groupSettingsProvider.notifier).update(updated);
    } finally {
      if (mounted) setState(() => setLoading(false));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                LoadingOverlay(
                  isLoading: _weekStartLoading,
                  child: SettingsRowWidget(
                    label: 'Wochenstart',
                    controlWidget: WeekStartDaySegmentedButton(
                      groupSettings: groupSettings,
                      onGroupSettingsChanged: (updated) => _updateSetting(
                        updated: updated,
                        setLoading: (v) => _weekStartLoading = v,
                      ),
                    ),
                  ),
                ),
                LoadingOverlay(
                  isLoading: _mealSlotsLoading,
                  child: SettingsRowWidget(
                    label: 'Mahlzeiten',
                    controlWidget: MealSlotsSegmentedButton(
                      groupSettings: groupSettings,
                      onGroupSettingsChanged: (updated) => _updateSetting(
                        updated: updated,
                        setLoading: (v) => _mealSlotsLoading = v,
                      ),
                    ),
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
