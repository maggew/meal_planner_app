import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';

class AddEditRecipeSectionHeaderItem extends StatefulWidget {
  final TextEditingController titleController;
  final bool isEditable;
  final bool sectionHasNoIngredient;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onConfirmPressed;
  final VoidCallback? onMoveUpPressed;
  final VoidCallback? onMoveDownPressed;
  final bool shouldRequestFocus;
  final bool isFirstSection;
  const AddEditRecipeSectionHeaderItem({
    super.key,
    required this.titleController,
    required this.isEditable,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.onConfirmPressed,
    this.onMoveUpPressed,
    this.onMoveDownPressed,
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final BorderRadius borderRadius = widget.sectionHasNoIngredient
        ? AppDimensions.borderRadiusAll
        : BorderRadius.vertical(
            top: Radius.circular(AppDimensions.borderRadius));

    return AnimatedContainer(
      duration: AppDimensions.animationDuration,
      decoration: BoxDecoration(
        color: colorScheme.primary,
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
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      widget.titleController.text,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
          ),
          if (widget.isEditable) ...[
            IconButton(
                key: const ValueKey("confirm"),
                onPressed: widget.onConfirmPressed,
                icon: Icon(Icons.check, color: colorScheme.onPrimary)),
          ] else ...[
            if (!widget.isFirstSection) ...[
              IconButton(
                  key: const ValueKey("delete"),
                  onPressed: widget.onDeletePressed,
                  icon: Icon(Icons.delete, color: colorScheme.onPrimary)),
            ],
            IconButton(
                key: const ValueKey("edit"),
                onPressed: widget.onEditPressed,
                icon: Icon(Icons.edit, color: colorScheme.onPrimary)),
            if (widget.onMoveUpPressed != null ||
                widget.onMoveDownPressed != null)
              PopupMenuButton<String>(
                icon: Icon(Icons.swap_vert,
                    color: colorScheme.onPrimary),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'up') widget.onMoveUpPressed?.call();
                  if (value == 'down') widget.onMoveDownPressed?.call();
                },
                itemBuilder: (context) => [
                  if (widget.onMoveUpPressed != null)
                    const PopupMenuItem(
                      value: 'up',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, size: 20),
                          SizedBox(width: 8),
                          Text('Nach oben'),
                        ],
                      ),
                    ),
                  if (widget.onMoveDownPressed != null)
                    const PopupMenuItem(
                      value: 'down',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, size: 20),
                          SizedBox(width: 8),
                          Text('Nach unten'),
                        ],
                      ),
                    ),
                ],
              ),
          ]
        ],
      ),
    );
  }
}
