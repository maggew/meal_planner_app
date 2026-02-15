import 'package:meal_planner/domain/enums/unit.dart';

class ShoppingListInputParser {
  static ({String? quantity, String information}) parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return (quantity: null, information: '');

    // 1. Versuch: Zahl + Einheit am Anfang → "500g Mehl"
    final startRegex = RegExp(
      r'^(\d+[.,]?\d*)\s*([a-zA-ZäöüÄÖÜ.]+)?\s*(.*)',
      caseSensitive: false,
    );

    final startMatch = startRegex.firstMatch(trimmed);
    if (startMatch != null) {
      final number = startMatch.group(1);
      final unitStr = startMatch.group(2);
      final rest = startMatch.group(3)?.trim();

      if (unitStr != null && UnitParser.parse(unitStr) != null) {
        final quantity = '$number$unitStr';
        return (
          quantity: quantity,
          information: rest != null && rest.isNotEmpty ? rest : trimmed,
        );
      }

      if (number != null) {
        final info = [unitStr, rest].whereType<String>().join(' ').trim();
        return (
          quantity: number,
          information: info.isNotEmpty ? info : trimmed,
        );
      }
    }

    // 2. Versuch: Zahl + Einheit am Ende → "Mehl 500g"
    final endRegex = RegExp(
      r'^(.+?)\s+(\d+[.,]?\d*)\s*([a-zA-ZäöüÄÖÜ.]+)?$',
      caseSensitive: false,
    );

    final endMatch = endRegex.firstMatch(trimmed);
    if (endMatch != null) {
      final info = endMatch.group(1)?.trim() ?? '';
      final number = endMatch.group(2);
      final unitStr = endMatch.group(3);

      if (unitStr != null && UnitParser.parse(unitStr) != null) {
        return (quantity: '$number$unitStr', information: info);
      }

      if (number != null) {
        return (quantity: number, information: info);
      }
    }

    return (quantity: null, information: trimmed);
  }
}

