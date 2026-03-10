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
  });
}
