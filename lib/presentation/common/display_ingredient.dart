import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';

class DisplayIngredient extends StatelessWidget {
  final Ingredient ingredient;
  const DisplayIngredient({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    String displayAmount = ingredient.amount ?? '';
    String displayUnit = ingredient.unit?.displayName ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 75,
          child: Text(
            "$displayAmount $displayUnit",
          ),
        ),
        Expanded(child: Text(ingredient.name)),
      ],
    );
  }
}
