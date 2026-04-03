import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/form/ingredient_form_item.dart';

class IngredientSectionForm {
  final TextEditingController titleController;
  final List<IngredientFormItem> items;
  final String? linkedRecipeId;
  bool isEditable;
  bool shouldRequestFocus;

  IngredientSectionForm({
    String? title,
    required this.items,
    this.linkedRecipeId,
    this.isEditable = false,
    this.shouldRequestFocus = false,
  }) : titleController = TextEditingController(text: title ?? '');

  bool get isLinked => linkedRecipeId != null;

  void dispose() {
    titleController.dispose();
  }
}
