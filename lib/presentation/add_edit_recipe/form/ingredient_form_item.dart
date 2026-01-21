import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

class IngredientFormItem {
  Ingredient ingredient;
  final TextEditingController nameController;
  final TextEditingController amountController;
  Unit unit;

  IngredientFormItem({
    required this.ingredient,
    required this.nameController,
    required this.amountController,
    required this.unit,
  });

  factory IngredientFormItem.fromIngredient(Ingredient ingredient) {
    return IngredientFormItem(
      ingredient: ingredient,
      unit: ingredient.unit,
      nameController: TextEditingController(text: ingredient.name),
      amountController: TextEditingController(
        text: ingredient.amount.isNotEmpty ? ingredient.amount : '',
      ),
    );
  }

  factory IngredientFormItem.empty() {
    return IngredientFormItem.fromIngredient(
      Ingredient(
        name: '',
        amount: '',
        unit: DEFAULT_UNIT,
      ),
    );
  }

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

