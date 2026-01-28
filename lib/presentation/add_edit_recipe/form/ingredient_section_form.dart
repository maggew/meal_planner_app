import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_form_item.dart';

class IngredientSectionForm {
  final TextEditingController titleController;
  final List<IngredientFormItem> items;
  bool isEditable;

  IngredientSectionForm({
    String? title,
    required this.items,
    this.isEditable = false,
  }) : titleController = TextEditingController(text: title ?? '');

  void dispose() {
    titleController.dispose();
    for (final item in items) {
      item.dispose();
    }
  }
}
