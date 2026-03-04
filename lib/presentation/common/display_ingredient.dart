import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/presentation/common/extensions/ingredient_inline_text_extenstion.dart';

class DisplayIngredient extends StatelessWidget {
  final Ingredient ingredient;
  const DisplayIngredient({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final (displayAmount, displayUnit) = ingredient.displayAmountAndUnit;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        SizedBox(
          width: 65,
          child: Text(
            "$displayAmount $displayUnit",
          ),
        ),
        Expanded(child: Text(ingredient.name)),
      ],
    );
  }
}
