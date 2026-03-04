import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/categories.dart';
import 'package:meal_planner/data/repositories/supabase_group_category_repository.dart';
import 'package:meal_planner/domain/entities/group_category.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/services/providers/groups/group_category_provider.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';

class CategoryManagementSection extends ConsumerStatefulWidget {
  const CategoryManagementSection({super.key});

  @override
  ConsumerState<CategoryManagementSection> createState() =>
      _CategoryManagementSectionState();
}

class _CategoryManagementSectionState
    extends ConsumerState<CategoryManagementSection> {
  bool _isLoading = false;

  Future<void> _runWithLoading(Future<void> Function() action) async {
    setState(() => _isLoading = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(groupCategoriesProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Fehler: $e'),
      data: (categories) => LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategorien',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (!isOnline) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.cloud_off_outlined,
                      size: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4)),
                  const SizedBox(width: 6),
                  Text(
                    'Nur online bearbeitbar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                        ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              onReorder: isOnline && !_isLoading
                  ? (oldIndex, newIndex) =>
                      _onReorder(categories, oldIndex, newIndex)
                  : (_, __) {},
              itemBuilder: (context, index) => _CategoryTile(
                key: ValueKey(categories[index].id),
                category: categories[index],
                index: index,
                isOnline: isOnline && !_isLoading,
                onAction: _runWithLoading,
              ),
            ),
            if (isOnline)
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Neue Kategorie'),
                onPressed: _isLoading ? null : () => _showAddDialog(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onReorder(
      List<GroupCategory> categories, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final newList = [...categories];
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    await _runWithLoading(() async {
      try {
        await ref
            .read(groupCategoriesProvider.notifier)
            .reorderCategories(newList);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Reihenfolge konnte nicht gespeichert werden: $e')),
          );
        }
      }
    });
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<({String name, String? iconName})>(
      context: context,
      builder: (context) => const _CategoryFormDialog(
        title: 'Kategorie hinzufügen',
        confirmLabel: 'Hinzufügen',
      ),
    );

    if (result != null && result.name.isNotEmpty) {
      await _runWithLoading(() async {
        try {
          await ref
              .read(groupCategoriesProvider.notifier)
              .addCategory(result.name, iconName: result.iconName);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fehler: $e')),
            );
          }
        }
      });
    }
  }
}

// ---------------------------------------------------------------------------
// Icon-Picker Dialog
// ---------------------------------------------------------------------------

class _CategoryFormDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final String initialName;
  final String? initialIconName;

  const _CategoryFormDialog({
    required this.title,
    required this.confirmLabel,
    this.initialName = '',
    this.initialIconName,
  });

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late final TextEditingController _controller;
  String? _selectedIconName;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _selectedIconName = widget.initialIconName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: widget.initialName.isEmpty,
            decoration: const InputDecoration(hintText: 'Kategoriename'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          Text(
            'Icon',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categoryIconOptions.entries.map((entry) {
              final isSelected = _selectedIconName == entry.key;
              return GestureDetector(
                onTap: () => setState(() => _selectedIconName = entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Icon(
                    entry.value,
                    size: 24,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(context, (name: name, iconName: _selectedIconName));
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Category Tile
// ---------------------------------------------------------------------------

class _CategoryTile extends ConsumerWidget {
  final GroupCategory category;
  final int index;
  final bool isOnline;
  final Future<void> Function(Future<void> Function()) onAction;

  const _CategoryTile({
    super.key,
    required this.category,
    required this.index,
    required this.isOnline,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: isOnline
          ? ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle_outlined),
            )
          : const Icon(Icons.drag_handle_outlined, color: Colors.transparent),
      title: Row(
        children: [
          Icon(
            getCategoryIconData(category.name, iconName: category.iconName),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(category.name),
        ],
      ),
      trailing: isOnline
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Bearbeiten',
                  onPressed: () => _showEditDialog(context, ref),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Löschen',
                  onPressed: () => _showDeleteDialog(context, ref),
                ),
              ],
            )
          : null,
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({String name, String? iconName})>(
      context: context,
      builder: (context) => _CategoryFormDialog(
        title: 'Kategorie bearbeiten',
        confirmLabel: 'Speichern',
        initialName: category.name,
        initialIconName: category.iconName,
      ),
    );

    if (result != null && result.name.isNotEmpty) {
      await onAction(() async {
        try {
          await ref
              .read(groupCategoriesProvider.notifier)
              .updateCategory(category.id, result.name, result.iconName);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fehler: $e')),
            );
          }
        }
      });
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategorie löschen'),
        content: Text('Möchtest du "${category.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await onAction(() async {
        try {
          await ref
              .read(groupCategoriesProvider.notifier)
              .deleteCategory(category.id);
        } on CategoryInUseException catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kann nicht gelöscht werden: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fehler: $e')),
            );
          }
        }
      });
    }
  }
}
