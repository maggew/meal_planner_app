import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';

extension IngredientInlineText on Ingredient {
  List<TextSpan> toInlineTextSpans({required TextStyle? nameStyle}) {
    final nbsp = '\u00A0';

    return [
      TextSpan(
        text: "$amount${nbsp}${unit?.displayName}${nbsp}",
      ),
      TextSpan(
        text: _noBreak(name),
        style: nameStyle,
      ),
    ];
  }
}

String _noBreak(String value) => value.replaceAll(' ', '\u00A0');
