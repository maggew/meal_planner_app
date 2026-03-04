import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';

extension IngredientInlineText on Ingredient {
  /// Gibt `(displayAmount, displayUnit)` zurück.
  /// Konvertiert automatisch: g→kg und ml→l ab 1000.
  (String, String) get displayAmountAndUnit {
    final value = amount != null ? double.tryParse(amount!) : null;
    if (value != null && value >= 1000) {
      if (unit == Unit.GRAMM) return (_fmtUnit(value / 1000), 'kg');
      if (unit == Unit.MILLILITER) return (_fmtUnit(value / 1000), 'l');
    }
    return (amount ?? '', unit?.displayName ?? '');
  }

  List<TextSpan> toInlineTextSpans({required TextStyle? nameStyle}) {
    final nbsp = '\u00A0';
    final (dispAmount, dispUnit) = displayAmountAndUnit;

    return [
      if (unit == null && amount == null)
        ...[
      ] else if (unit == null) ...[
        TextSpan(text: '$dispAmount '),
      ] else ...[
        TextSpan(text: '$dispAmount$nbsp$dispUnit '),
      ],
      TextSpan(
        text: name,
        style: nameStyle,
      ),
    ];
  }
}

String _fmtUnit(double v) {
  if (v % 1 == 0) return v.toInt().toString();
  return v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
}
