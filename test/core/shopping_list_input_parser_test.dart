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

    group('Edge Cases mit irreführenden quantity/information-Werten', () {
      test('BUG - nur eine Zahl: information = quantity = "500" → zeigt "500 500" in der UI', () {
        // Benutzer tippt "500" ohne Namen → quantity und information sind identisch
        final result = ShoppingListInputParser.parse('500');
        expect(result.quantity, '500');
        // Bug: information sollte leer sein oder der Nutzer sollte gewarnt werden,
        // stattdessen wird die Zahl doppelt gespeichert
        expect(result.information, '500');
      });

      test('BUG - einstellige Zahl: "3" → information = quantity = "3"', () {
        final result = ShoppingListInputParser.parse('3');
        expect(result.quantity, '3');
        expect(result.information, '3');
      });
    });
  });
}
