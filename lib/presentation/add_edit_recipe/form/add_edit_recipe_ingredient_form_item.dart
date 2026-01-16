import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

class IngredientFormItem {
  final Ingredient ingredient;
  final TextEditingController nameController;
  final TextEditingController amountController;

  IngredientFormItem({
    required this.ingredient,
    required this.nameController,
    required this.amountController,
  });

  factory IngredientFormItem.fromIngredient(Ingredient ingredient) {
    return IngredientFormItem(
      ingredient: ingredient,
      nameController: TextEditingController(text: ingredient.name),
      amountController: TextEditingController(
        text: ingredient.amount > 0 ? ingredient.amount.toString() : "0",
      ),
    );
  }

  factory IngredientFormItem.empty({String? groupName}) {
    return IngredientFormItem.fromIngredient(Ingredient(
      name: "",
      amount: 0,
      unit: DEFAULT_UNIT,
      sortOrder: 0,
      groupName: groupName,
    ));
  }

  IngredientFormItem copyWith({
    Ingredient? ingredient,
  }) {
    return IngredientFormItem(
      ingredient: ingredient ?? this.ingredient,
      nameController: nameController,
      amountController: amountController,
    );
  }

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}
