import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';

extension IngredientInlineText on Ingredient {
  List<TextSpan> toInlineTextSpans({required TextStyle? nameStyle}) {
    final nbsp = '\u00A0';

    return [
      if (unit == null && amount == null)
        ...[
      ] else if (unit == null) ...[
        TextSpan(
          text: "$amount ",
        ),
      ] else ...[
        TextSpan(
          text: "$amount${nbsp}${unit?.displayName} ",
        ),
      ],
      TextSpan(
        text: name,
        style: nameStyle,
      ),
    ];
  }
}
