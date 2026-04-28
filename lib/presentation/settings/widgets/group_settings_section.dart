import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/core/utils/uuid_generator.dart';
import 'package:meal_planner/data/repositories/supabase_group_category_repository.dart';
import 'package:meal_planner/domain/entities/group_category.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/presentation/settings/widgets/category_management_section.dart';
import 'package:meal_planner/presentation/settings/widgets/control_widgets/meal_slots_segmented_button.dart';
import 'package:meal_planner/presentation/settings/widgets/control_widgets/week_start_day_segmented_button.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
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
    final isAdmin = ref.watch(sessionProvider).isAdmin;
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
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_isEditing) ...[
                InkWell(
                  key: const ValueKey('cancel'),
                  onTap: _isSaving ? null : _cancelEditing,
                  borderRadius: BorderRadius.circular(4),
                  child: Tooltip(
                    message: 'Abbrechen',
                    child: Icon(Icons.close, size: 18, color: colorScheme.onSurface),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  key: const ValueKey('save'),
                  onTap: _isSaving ? null : _save,
                  borderRadius: BorderRadius.circular(4),
                  child: Tooltip(
                    message: 'Speichern',
                    child: Icon(Icons.save_outlined, size: 18, color: colorScheme.onSurface),
                  ),
                ),
              ] else
                isOnline
                    ? InkWell(
                        key: const ValueKey('edit'),
                        onTap: _startEditing,
                        borderRadius: BorderRadius.circular(4),
                        child: Tooltip(
                          message: 'Bearbeiten',
                          child: Icon(Icons.edit_outlined, size: 18, color: colorScheme.onSurface),
                        ),
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
          const Divider(thickness: 1),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rezept-Vorschläge',
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  _WeightSettingRow(
                    label: 'Rezept-Rotation',
                    subtitle:
                        'Wie stark bevorzugt werden Rezepte, die selten oder noch nie gekocht wurden',
                    value: displaySettings.rotationWeight,
                    onChanged: _isEditing
                        ? (v) => _onSettingsChanged(
                              displaySettings.copyWith(rotationWeight: v),
                            )
                        : (_) {},
                  ),
                  _WeightSettingRow(
                    label: 'KH-Abwechslung',
                    subtitle:
                        'Wie stark werden Kohlenhydrat-Wiederholungen in den letzten Tagen vermieden',
                    value: displaySettings.carbVarietyWeight,
                    onChanged: _isEditing
                        ? (v) => _onSettingsChanged(
                              displaySettings.copyWith(carbVarietyWeight: v),
                            )
                        : (_) {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CategoryManagementSection(
            isEditing: _isEditing,
            categories: displayCategories,
            categoriesLoading: !_isEditing && categoriesAsync.isLoading,
            onAdd: _onAddCategory,
            onEdit: _onEditCategory,
            onDelete: _onDeleteCategory,
            onReorder: _onReorderCategories,
          ),
          if (isAdmin) ...[
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            InkWell(
              onTap: isOnline
                  ? () => context.router.push(const TrashRoute())
                  : null,
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: isOnline
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Papierkorb',
                        style: textTheme.bodyMedium?.copyWith(
                          color: isOnline
                              ? null
                              : colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: colorScheme.onSurface
                          .withValues(alpha: isOnline ? 0.5 : 0.25),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

class _WeightSettingRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final int value;
  final ValueChanged<int>? onChanged;

  const _WeightSettingRow({
    required this.label,
    required this.subtitle,
    required this.value,
    this.onChanged,
  });

  static const _labels = ['Aus', 'Niedrig', 'Mittel', 'Hoch'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodyMedium),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              selected: {value},
              onSelectionChanged:
                  onChanged != null ? (s) => onChanged!(s.first) : null,
              showSelectedIcon: false,
              segments: [
                for (int i = 0; i < _labels.length; i++)
                  ButtonSegment(value: i, label: Text(_labels[i])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
