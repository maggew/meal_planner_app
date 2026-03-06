import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/utils/uuid_generator.dart';
import 'package:meal_planner/data/repositories/supabase_group_category_repository.dart';
import 'package:meal_planner/domain/entities/group_category.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/presentation/settings/widgets/category_management_section.dart';
import 'package:meal_planner/presentation/settings/widgets/control_widgets/meal_slots_segmented_button.dart';
import 'package:meal_planner/presentation/settings/widgets/control_widgets/week_start_day_segmented_button.dart';
import 'package:meal_planner/presentation/settings/widgets/settings_row_widget.dart';
import 'package:meal_planner/services/providers/groups/group_category_provider.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/user/group_settings_provider.dart';

class GroupSettingsSection extends ConsumerStatefulWidget {
  final void Function(bool)? onEditingChanged;

  const GroupSettingsSection({super.key, this.onEditingChanged});

  @override
  ConsumerState<GroupSettingsSection> createState() =>
      _GroupSettingsSectionState();
}

class _GroupSettingsSectionState extends ConsumerState<GroupSettingsSection> {
  bool _isEditing = false;
  bool _isSaving = false;
  GroupSettings? _localSettings;
  List<GroupCategory>? _localCategories;
  Set<String> _originalCategoryIds = {};
  List<String> _deletedCategoryIds = [];

  void _startEditing() {
    final settings = ref.read(groupSettingsProvider);
    final categories = ref.read(groupCategoriesProvider).value ?? [];
    setState(() {
      _localSettings = settings;
      _localCategories = [...categories];
      _originalCategoryIds = {for (final c in categories) c.id};
      _deletedCategoryIds = [];
      _isEditing = true;
    });
    widget.onEditingChanged?.call(true);
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _localSettings = null;
      _localCategories = null;
      _originalCategoryIds = {};
      _deletedCategoryIds = [];
    });
    widget.onEditingChanged?.call(false);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      // 1. Save group settings (one Supabase call)
      await ref.read(groupSettingsProvider.notifier).update(_localSettings!);

      // 2. Batch-save categories (delete removed + upsert remaining)
      final groupId = ref.read(sessionProvider).groupId!;
      final ordered = [
        for (int i = 0; i < _localCategories!.length; i++)
          _localCategories![i].copyWith(sortOrder: i),
      ];
      await ref.read(groupCategoriesProvider.notifier).syncCategories(
            groupId,
            ordered,
            _deletedCategoryIds,
          );

      if (mounted) {
        setState(() {
          _isEditing = false;
          _localSettings = null;
          _localCategories = null;
          _originalCategoryIds = {};
          _deletedCategoryIds = [];
        });
        widget.onEditingChanged?.call(false);
      }
    } on CategoryInUseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kategorie kann nicht gelöscht werden: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onSettingsChanged(GroupSettings updated) {
    setState(() => _localSettings = updated);
  }

  void _onAddCategory(String name, String? iconName) {
    final groupId = ref.read(sessionProvider).groupId!;
    final newCategory = GroupCategory(
      id: generateUuid(),
      groupId: groupId,
      name: name,
      sortOrder: _localCategories!.length,
      iconName: iconName,
    );
    setState(() => _localCategories!.add(newCategory));
  }

  void _onEditCategory(String id, String name, String? iconName) {
    setState(() {
      final idx = _localCategories!.indexWhere((c) => c.id == id);
      if (idx >= 0) {
        _localCategories![idx] =
            _localCategories![idx].copyWith(name: name, iconName: iconName);
      }
    });
  }

  void _onDeleteCategory(String id) {
    setState(() {
      _localCategories!.removeWhere((c) => c.id == id);
      // Only track for deletion if it was originally persisted in Supabase
      if (_originalCategoryIds.contains(id)) {
        _deletedCategoryIds.add(id);
      }
    });
  }

  void _onReorderCategories(List<GroupCategory> newList) {
    setState(() => _localCategories = newList);
  }

  @override
  Widget build(BuildContext context) {
    final groupSettings = ref.watch(groupSettingsProvider);
    final categoriesAsync = ref.watch(groupCategoriesProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final displaySettings = _isEditing ? _localSettings! : groupSettings;
    final displayCategories =
        _isEditing ? _localCategories! : (categoriesAsync.value ?? []);

    return LoadingOverlay(
      isLoading: _isSaving,
      child: Column(
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
              const Spacer(),
              if (!_isEditing)
                isOnline
                    ? IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Bearbeiten',
                        onPressed: _startEditing,
                      )
                    : Icon(
                        Icons.cloud_off_outlined,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
            ],
          ),
          if (!isOnline && !_isEditing) ...[
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
            ignoring: !_isEditing,
            child: Opacity(
              opacity: _isEditing ? 1.0 : 0.7,
              child: Column(
                children: [
                  SettingsRowWidget(
                    label: 'Wochenstart',
                    controlWidget: WeekStartDaySegmentedButton(
                      groupSettings: displaySettings,
                      onGroupSettingsChanged: _isEditing
                          ? _onSettingsChanged
                          : (_) {},
                    ),
                  ),
                  SettingsRowWidget(
                    label: 'Mahlzeiten',
                    controlWidget: MealSlotsSegmentedButton(
                      groupSettings: displaySettings,
                      onGroupSettingsChanged: _isEditing
                          ? _onSettingsChanged
                          : (_) {},
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Kohlenhydrat-Bewertung',
                      style: textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      'Berücksichtigt KH-Vielfalt bei Rezeptvorschlägen',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    value: displaySettings.showCarbTags,
                    onChanged: _isEditing
                        ? (v) => _onSettingsChanged(
                              displaySettings.copyWith(showCarbTags: v),
                            )
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CategoryManagementSection(
            isEditing: _isEditing,
            categories: displayCategories,
            categoriesLoading:
                !_isEditing && categoriesAsync.isLoading,
            onAdd: _onAddCategory,
            onEdit: _onEditCategory,
            onDelete: _onDeleteCategory,
            onReorder: _onReorderCategories,
          ),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 12,
              children: [
                OutlinedButton(
                  onPressed: _isSaving ? null : _cancelEditing,
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: const Text('Speichern'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
