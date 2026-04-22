import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/core/constants/categories.dart';
import 'package:meal_planner/domain/entities/group_category.dart';

class CategoryManagementSection extends StatefulWidget {
  final bool isEditing;
  final List<GroupCategory> categories;
  final bool categoriesLoading;
  final void Function(String name, String? iconName) onAdd;
  final void Function(String id, String name, String? iconName) onEdit;
  final void Function(String id) onDelete;
  final void Function(List<GroupCategory> newList) onReorder;

  const CategoryManagementSection({
    super.key,
    required this.isEditing,
    required this.categories,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
    this.categoriesLoading = false,
  });

  @override
  State<CategoryManagementSection> createState() =>
      _CategoryManagementSectionState();
}

class _CategoryManagementSectionState
    extends State<CategoryManagementSection> {
  Future<void> _showAddDialog() async {
    final result = await showModalBottomSheet<({String name, String? iconName})>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _CategoryFormSheet(
        title: 'Kategorie hinzufügen',
        confirmLabel: 'Hinzufügen',
      ),
    );
    if (result != null && result.name.isNotEmpty) {
      widget.onAdd(result.name, result.iconName);
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final newList = [...widget.categories];
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    widget.onReorder(newList);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categoriesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategorien',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.categories.length,
          onReorder: widget.isEditing ? _onReorder : (_, __) {},
          proxyDecorator: (child, index, animation) => Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
          itemBuilder: (context, index) => _CategoryTile(
            key: ValueKey(widget.categories[index].id),
            category: widget.categories[index],
            index: index,
            isEditing: widget.isEditing,
            onEdit: (name, iconName) =>
                widget.onEdit(widget.categories[index].id, name, iconName),
            onDelete: () => widget.onDelete(widget.categories[index].id),
          ),
        ),
        if (widget.isEditing)
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Neue Kategorie'),
            onPressed: _showAddDialog,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Icon-Picker Bottom Sheet
// ---------------------------------------------------------------------------

class _CategoryFormSheet extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final String initialName;
  final String? initialIconName;

  const _CategoryFormSheet({
    required this.title,
    required this.confirmLabel,
    this.initialName = '',
    this.initialIconName,
  });

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
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
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            autofocus: widget.initialName.isEmpty,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
          ),
          const SizedBox(height: 20),
          Text(
            'Icon',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
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
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                  ),
                  child: Icon(
                    entry.value,
                    size: 24,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Abbrechen'),
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final name = _controller.text.trim();
                    if (name.isEmpty) return;
                    Navigator.pop(
                        context, (name: name, iconName: _selectedIconName));
                  },
                  child: Text(widget.confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category Tile
// ---------------------------------------------------------------------------

class _CategoryTile extends StatelessWidget {
  final GroupCategory category;
  final int index;
  final bool isEditing;
  final void Function(String name, String? iconName) onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    super.key,
    required this.category,
    required this.index,
    required this.isEditing,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
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
      trailing: isEditing
          ? Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Bearbeiten',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showEditDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Löschen',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showDeleteDialog(context),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle_outlined),
                ),
              ],
            )
          : null,
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final result = await showModalBottomSheet<({String name, String? iconName})>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CategoryFormSheet(
        title: 'Kategorie bearbeiten',
        confirmLabel: 'Speichern',
        initialName: category.name,
        initialIconName: category.iconName,
      ),
    );
    if (result != null && result.name.isNotEmpty) {
      onEdit(result.name, result.iconName);
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
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
    if (confirmed == true) onDelete();
  }
}
