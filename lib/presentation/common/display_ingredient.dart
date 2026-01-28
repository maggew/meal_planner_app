import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';

class DisplayIngredient extends StatelessWidget {
  final Ingredient ingredient;
  const DisplayIngredient({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 75,
          child: Text(
            "${ingredient.amount} ${ingredient.unit.displayName}",
          ),
        ),
        Expanded(child: Text(ingredient.name)),
      ],
    );
  }
}
