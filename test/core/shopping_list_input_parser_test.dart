import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/utils/shopping_list_input_parser.dart';

void main() {
  group('ShoppingListInputParser.parse', () {
    group('normaler Input', () {
      test('parst Menge + Einheit + Name am Anfang', () {
        final result = ShoppingListInputParser.parse('500g Mehl');
        expect(result.information, 'Mehl');
        expect(result.quantity, '500g');
      });

      test('parst Name + Menge + Einheit am Ende', () {
        final result = ShoppingListInputParser.parse('Mehl 500g');
        expect(result.information, 'Mehl');
        expect(result.quantity, '500g');
      });

      test('parst reinen Namen ohne Menge', () {
        final result = ShoppingListInputParser.parse('Tomaten');
        expect(result.information, 'Tomaten');
        expect(result.quantity, isNull);
      });
    });

    group('Edge Cases die zu leerem information führen', () {
      test('leerer String → information ist leer', () {
        final result = ShoppingListInputParser.parse('');
        // information ist '' — ShoppingListItemTile crasht bei information[0]
        expect(result.information, isEmpty);
        expect(result.quantity, isNull);
      });

      test('nur Whitespace → information ist leer', () {
        final result = ShoppingListInputParser.parse('   ');
        // information ist '' — ShoppingListItemTile crasht bei information[0]
        expect(result.information, isEmpty);
        expect(result.quantity, isNull);
      });
    });

    group('Zahl ohne Namen → keine quantity', () {
      test('"500" → quantity null, information "500" (kein Doppel-Anzeigebug)', () {
        final result = ShoppingListInputParser.parse('500');
        expect(result.quantity, isNull);
        expect(result.information, '500');
      });

      test('"3" → quantity null, information "3"', () {
        final result = ShoppingListInputParser.parse('3');
        expect(result.quantity, isNull);
        expect(result.information, '3');
      });

      test('"3 Eier" → quantity "3", information "Eier" (Zahl+Name bleibt korrekt)', () {
        final result = ShoppingListInputParser.parse('3 Eier');
        expect(result.quantity, '3');
        expect(result.information, 'Eier');
      });
    });

    group('Einheit ohne Namen → keine quantity', () {
      test('"500g" → quantity null, information "500g"', () {
        final result = ShoppingListInputParser.parse('500g');
        expect(result.quantity, isNull);
        expect(result.information, '500g');
      });

      test('"2el" → quantity null, information "2el"', () {
        final result = ShoppingListInputParser.parse('2el');
        expect(result.quantity, isNull);
        expect(result.information, '2el');
      });

      test('"1 Dose" → quantity null, information "1 Dose"', () {
        final result = ShoppingListInputParser.parse('1 Dose');
        expect(result.quantity, isNull);
        expect(result.information, '1 Dose');
      });

      test('"500g Mehl" → bleibt korrekt (unit + Name)', () {
        final result = ShoppingListInputParser.parse('500g Mehl');
        expect(result.quantity, '500g');
        expect(result.information, 'Mehl');
      });

      test('"1,5kg Mehl" → Komma-Dezimal mit Einheit und Name', () {
        final result = ShoppingListInputParser.parse('1,5kg Mehl');
        expect(result.quantity, '1,5kg');
        expect(result.information, 'Mehl');
      });

      test('"500 g Mehl" → Leerzeichen zwischen Zahl und Einheit', () {
        final result = ShoppingListInputParser.parse('500 g Mehl');
        expect(result.quantity, '500g');
        expect(result.information, 'Mehl');
      });
    });
  });
}
