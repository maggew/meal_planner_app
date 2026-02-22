import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';

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
        ? AppDimensions.borderRadiusAll
        : BorderRadius.vertical(
            top: Radius.circular(AppDimensions.borderRadius));

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppDimensions.animationDuration,
      decoration: BoxDecoration(
        color: colorScheme.secondary,
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
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ),
          ),
          if (widget.isEditable) ...[
            IconButton(
                key: const ValueKey("confirm"),
                onPressed: widget.onConfirmPressed,
                icon: Icon(
                  Icons.check,
                  color: colorScheme.onSecondary,
                )),
          ] else ...[
            if (!widget.isFirstSection) ...[
              IconButton(
                  key: const ValueKey("delete"),
                  onPressed: widget.onDeletePressed,
                  icon: Icon(
                    Icons.delete,
                    color: colorScheme.onSecondary,
                  )),
            ],
            IconButton(
                key: const ValueKey("edit"),
                onPressed: widget.onEditPressed,
                icon: Icon(
                  Icons.edit,
                  color: colorScheme.onSecondary,
                )),
          ]
        ],
      ),
    );
  }
}
