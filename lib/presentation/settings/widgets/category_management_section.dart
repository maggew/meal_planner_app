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
    final result = await showDialog<({String name, String? iconName})>(
      context: context,
      builder: (context) => const _CategoryFormDialog(
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
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.categories.length,
          onReorder: widget.isEditing ? _onReorder : (_, __) {},
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
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: isEditing
          ? ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle_outlined),
            )
          : const Icon(Icons.drag_handle_outlined,
              color: Colors.transparent),
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
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Bearbeiten',
                  onPressed: () => _showEditDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Löschen',
                  onPressed: () => _showDeleteDialog(context),
                ),
              ],
            )
          : null,
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
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
