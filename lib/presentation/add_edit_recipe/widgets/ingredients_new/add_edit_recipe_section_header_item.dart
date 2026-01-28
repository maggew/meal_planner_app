import 'package:flutter/material.dart';

class AddEditRecipeSectionHeaderItem extends StatelessWidget {
  final TextEditingController titleController;
  final bool isEditable;
  final bool sectionHasNoIngredient;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onConfirmPressed;
  const AddEditRecipeSectionHeaderItem({
    super.key,
    required this.titleController,
    required this.isEditable,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.onConfirmPressed,
    required this.sectionHasNoIngredient,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final BorderRadius borderRadius = sectionHasNoIngredient
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
            child: isEditable
                ? TextFormField(
                    controller: titleController,
                    textAlign: TextAlign.center,
                  )
                : Center(
                    child: Text(
                      titleController.text,
                      style: textTheme.bodyLarge,
                    ),
                  ),
          ),
          if (isEditable) ...[
            IconButton(onPressed: onConfirmPressed, icon: Icon(Icons.check)),
          ] else ...[
            IconButton(onPressed: onDeletePressed, icon: Icon(Icons.delete)),
            IconButton(onPressed: onEditPressed, icon: Icon(Icons.edit)),
          ]
        ],
      ),
    );
  }
}
