import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

class IngredientFormItem {
  final String? id;
  Ingredient ingredient;
  final TextEditingController nameController;
  final TextEditingController amountController;
  Unit unit;
  bool isEditable;
  bool shouldRequestFocus;

  IngredientFormItem({
    String? id,
    required this.ingredient,
    required this.nameController,
    required this.amountController,
    required this.unit,
    required this.isEditable,
    this.shouldRequestFocus = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  factory IngredientFormItem.fromIngredient(Ingredient ingredient) {
    return IngredientFormItem(
      ingredient: ingredient,
      unit: ingredient.unit,
      nameController: TextEditingController(text: ingredient.name),
      amountController: TextEditingController(
        text: ingredient.amount.isNotEmpty ? ingredient.amount : '',
      ),
      isEditable: false,
    );
  }

  factory IngredientFormItem.empty() {
    IngredientFormItem item = IngredientFormItem.fromIngredient(
      Ingredient(
        name: '',
        amount: '',
        unit: DEFAULT_UNIT,
      ),
    );
    item.isEditable = true;
    item.shouldRequestFocus = true;
    return item;
  }

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}
