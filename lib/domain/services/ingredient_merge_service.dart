import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:meal_planner/domain/enums/unit.dart';

class MergeResult {
  final String itemId;
  final String itemName;
  final String? oldQuantity;
  final String? newQuantity;

  const MergeResult({
    required this.itemId,
    required this.itemName,
    required this.oldQuantity,
    required this.newQuantity,
  });
}

class IngredientMergeService {
  MergeResult? tryMerge(
    String name,
    String? quantity,
    List<ShoppingListItem> existingItems,
  ) {
    final normalizedName = name.trim().toLowerCase();

    for (final item in existingItems) {
      if (item.isChecked) continue;
      if (item.information.trim().toLowerCase() != normalizedName) continue;

      final existingParsed = _parseQuantity(item.quantity);
      final newParsed = _parseQuantity(quantity);

      final merged = _mergeQuantities(existingParsed, newParsed);
      if (merged == _noMerge) continue;

      return MergeResult(
        itemId: item.id,
        itemName: item.information,
        oldQuantity: item.quantity,
        newQuantity: merged,
      );
    }
    return null;
  }

  static ({double? amount, Unit? unit}) _parseQuantity(String? quantity) {
    if (quantity == null || quantity.trim().isEmpty) {
      return (amount: null, unit: null);
    }

    final regex = RegExp(r'^(\d+[.,]?\d*)\s*([a-zA-ZäöüÄÖÜ.]+)?$');
    final match = regex.firstMatch(quantity.trim());
    if (match == null) return (amount: null, unit: null);

    final numberStr = match.group(1)!.replaceAll(',', '.');
    final amount = double.tryParse(numberStr);
    final unitStr = match.group(2);
    final unit = unitStr != null ? UnitParser.parse(unitStr) : null;

    return (amount: amount, unit: unit);
  }

  static const _noMerge = '\x00';

  /// Returns merged quantity string, null for "both no quantity" merge,
  /// or [_noMerge] sentinel when merge is not possible.
  static String? _mergeQuantities(
    ({double? amount, Unit? unit}) existing,
    ({double? amount, Unit? unit}) incoming,
  ) {
    // Both have no quantity — merge with null quantity
    if (existing.amount == null && incoming.amount == null) {
      return null;
    }

    // One has quantity, other doesn't — can't merge
    if (existing.amount == null || incoming.amount == null) {
      return _noMerge;
    }

    // Check unit compatibility
    if (!_areUnitsCompatible(existing.unit, incoming.unit)) {
      return _noMerge;
    }

    // Convert to common unit and add
    final (existingAmount, incomingAmount, baseUnit) =
        _toCommonUnit(existing.amount!, existing.unit, incoming.amount!, incoming.unit);

    final total = existingAmount + incomingAmount;
    return _formatQuantity(total, baseUnit);
  }

  static bool _areUnitsCompatible(Unit? a, Unit? b) {
    if (a == b) return true;

    // no-unit and Stk. are compatible
    if ((a == null && b == Unit.PIECE) || (a == Unit.PIECE && b == null)) {
      return true;
    }

    // g ↔ kg
    if (_isWeight(a) && _isWeight(b)) return true;

    // ml ↔ l
    if (_isVolume(a) && _isVolume(b)) return true;

    return false;
  }

  static bool _isWeight(Unit? u) => u == Unit.GRAMM || u == Unit.KILOGRAMM;
  static bool _isVolume(Unit? u) => u == Unit.MILLILITER || u == Unit.LITER;

  static (double, double, Unit?) _toCommonUnit(
    double amountA, Unit? unitA,
    double amountB, Unit? unitB,
  ) {
    // no-unit / Stk. — treat as plain numbers
    if ((unitA == null || unitA == Unit.PIECE) &&
        (unitB == null || unitB == Unit.PIECE)) {
      // Keep Stk. only if both are Stk.
      final resultUnit =
          (unitA == Unit.PIECE && unitB == Unit.PIECE) ? Unit.PIECE : null;
      return (amountA, amountB, resultUnit);
    }

    // Convert to base unit (g or ml)
    final a = _toBaseUnit(amountA, unitA);
    final b = _toBaseUnit(amountB, unitB);
    final baseUnit = _isWeight(unitA) || _isWeight(unitB)
        ? Unit.GRAMM
        : Unit.MILLILITER;

    return (a, b, baseUnit);
  }

  static double _toBaseUnit(double amount, Unit? unit) {
    return switch (unit) {
      Unit.KILOGRAMM => amount * 1000,
      Unit.LITER => amount * 1000,
      _ => amount,
    };
  }

  static String _formatQuantity(double total, Unit? baseUnit) {
    // Threshold: ≥1000 → switch to large unit
    if (baseUnit == Unit.GRAMM && total >= 1000) {
      return '${_formatNumber(total / 1000)}kg';
    }
    if (baseUnit == Unit.MILLILITER && total >= 1000) {
      return '${_formatNumber(total / 1000)}l';
    }

    final unitStr = baseUnit?.displayName ?? '';
    final separator = baseUnit == Unit.PIECE ? ' ' : '';
    return '${_formatNumber(total)}$separator$unitStr';
  }

  static String _formatNumber(double value) {
    // Use comma as decimal separator
    if (value == value.roundToDouble() && value < 1e15) {
      return value.toInt().toString();
    }
    // Remove trailing zeros, use comma
    String str = value.toStringAsFixed(2);
    str = str.replaceAll(RegExp(r'0+$'), '');
    str = str.replaceAll(RegExp(r'\.$'), '');
    str = str.replaceAll('.', ',');
    return str;
  }
}
