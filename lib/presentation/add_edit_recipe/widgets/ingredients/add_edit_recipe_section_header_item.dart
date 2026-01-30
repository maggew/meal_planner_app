import 'package:flutter/material.dart';

class AddEditRecipeSectionHeaderItem extends StatefulWidget {
  final TextEditingController titleController;
  final bool isEditable;
  final bool sectionHasNoIngredient;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onConfirmPressed;
  final bool shouldRequestFocus;
  final bool isFirstSection;
  const AddEditRecipeSectionHeaderItem({
    super.key,
    required this.titleController,
    required this.isEditable,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.onConfirmPressed,
    required this.sectionHasNoIngredient,
    required this.shouldRequestFocus,
    required this.isFirstSection,
  });

  @override
  State<AddEditRecipeSectionHeaderItem> createState() =>
      _AddEditRecipeSectionHeaderItemState();
}

class _AddEditRecipeSectionHeaderItemState
    extends State<AddEditRecipeSectionHeaderItem> {
  late final FocusNode _nameFocusNode;

  void _requestFocusNode() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _nameFocusNode.requestFocus());
  }

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();

    if (widget.shouldRequestFocus) {
      _requestFocusNode();
    }
  }

  @override
  void didUpdateWidget(covariant AddEditRecipeSectionHeaderItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldRequestFocus && !oldWidget.shouldRequestFocus) {
      _requestFocusNode();
    }
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final BorderRadius borderRadius = widget.sectionHasNoIngredient
        ? BorderRadius.circular(8)
        : BorderRadius.vertical(top: Radius.circular(8));
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          Expanded(
            child: widget.isEditable
                ? TextField(
                    focusNode: _nameFocusNode,
                    controller: widget.titleController,
                    textAlign: TextAlign.center,
                    onSubmitted: (_) => widget.onConfirmPressed(),
                  )
                : Center(
                    child: Text(
                      widget.titleController.text,
                      style: textTheme.bodyLarge,
                    ),
                  ),
          ),
          if (widget.isEditable) ...[
            IconButton(
                key: const ValueKey("confirm"),
                onPressed: widget.onConfirmPressed,
                icon: Icon(Icons.check)),
          ] else ...[
            if (!widget.isFirstSection) ...[
              IconButton(
                  key: const ValueKey("delete"),
                  onPressed: widget.onDeletePressed,
                  icon: Icon(Icons.delete)),
            ],
            IconButton(
                key: const ValueKey("edit"),
                onPressed: widget.onEditPressed,
                icon: Icon(Icons.edit)),
          ]
        ],
      ),
    );
  }
}
