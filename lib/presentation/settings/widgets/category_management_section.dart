import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/data/repositories/supabase_group_category_repository.dart';
import 'package:meal_planner/domain/entities/group_category.dart';
import 'package:meal_planner/services/providers/groups/group_category_provider.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';

class CategoryManagementSection extends ConsumerWidget {
  const CategoryManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(groupCategoriesProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Fehler: $e'),
      data: (categories) => Column(
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
            onReorder: isOnline
                ? (oldIndex, newIndex) =>
                    _onReorder(ref, categories, oldIndex, newIndex)
                : (_, __) {},
            itemBuilder: (context, index) => _CategoryTile(
              key: ValueKey(categories[index].id),
              category: categories[index],
              index: index,
              isOnline: isOnline,
            ),
          ),
          if (isOnline)
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Neue Kategorie'),
              onPressed: () => _showAddDialog(context, ref),
            ),
        ],
      ),
    );
  }

  void _onReorder(WidgetRef ref, List<GroupCategory> categories, int oldIndex,
      int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final newList = [...categories];
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    ref.read(groupCategoriesProvider.notifier).reorderCategories(newList);
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategorie hinzufügen'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Kategoriename'),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      try {
        await ref
            .read(groupCategoriesProvider.notifier)
            .addCategory(controller.text.trim());
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler: $e')),
          );
        }
      }
    }
  }
}

class _CategoryTile extends ConsumerWidget {
  final GroupCategory category;
  final int index;
  final bool isOnline;

  const _CategoryTile({
    super.key,
    required this.category,
    required this.index,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(category.name),
      leading: isOnline
          ? ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle_outlined),
            )
          : const Icon(Icons.drag_handle_outlined,
              color: Colors.transparent),
      trailing: isOnline
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Umbenennen',
                  onPressed: () => _showRenameDialog(context, ref),
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

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: category.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategorie umbenennen'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      try {
        await ref
            .read(groupCategoriesProvider.notifier)
            .renameCategory(category.id, controller.text.trim());
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler: $e')),
          );
        }
      }
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
    }
  }
}
