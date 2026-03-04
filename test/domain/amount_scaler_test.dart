import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/domain/services/amount_scaler.dart';
import 'package:meal_planner/presentation/common/extensions/ingredient_inline_text_extenstion.dart';

void main() {
  group('AmountScaler.scale()', () {
    // --- Ganze Zahlen ---
    test('skaliert ganze Zahl hoch', () {
      expect(AmountScaler.scale('150', 2), '300');
    });

    test('skaliert ganze Zahl runter', () {
      expect(AmountScaler.scale('100', 0.5), '50');
    });

    test('Faktor 1.0 lässt Wert unverändert', () {
      expect(AmountScaler.scale('200', 1.0), '200');
    });

    test('Ergebnis ohne unnötige Dezimalstellen', () {
      // 3 * (1/3) = 1.0 → "1", nicht "1.00"
      expect(AmountScaler.scale('3', 1 / 3), '1');
    });

    test('Dezimalstellen werden auf 2 begrenzt', () {
      // 3 * 0.75 = 2.25
      expect(AmountScaler.scale('3', 0.75), '2.25');
    });

    // --- Dezimalzahlen ---
    test('skaliert Dezimalzahl', () {
      expect(AmountScaler.scale('1.5', 2), '3');
    });

    test('skaliert Dezimalzahl mit nicht-glattem Ergebnis', () {
      expect(AmountScaler.scale('2.5', 3), '7.5');
    });

    test('entfernt abschließende Nullen', () {
      // 1.50 → "1.5"
      expect(AmountScaler.scale('1.5', 1), '1.5');
    });

    // --- Bereiche ---
    test('skaliert Bereich mit Bindestrich', () {
      expect(AmountScaler.scale('100-200', 2), '200-400');
    });

    test('skaliert Bereich mit Gedankenstrich (–)', () {
      expect(AmountScaler.scale('100–200', 2), '200-400');
    });

    test('skaliert Bereich mit Dezimalzahlen', () {
      expect(AmountScaler.scale('1.5-2.5', 2), '3-5');
    });

    // --- Brüche ---
    test('skaliert Bruch 1/2 × 2 = 1', () {
      expect(AmountScaler.scale('1/2', 2), '1');
    });

    test('skaliert Bruch 1/4 × 4 = 1', () {
      expect(AmountScaler.scale('1/4', 4), '1');
    });

    test('skaliert Bruch 3/4 × 2 = 1.5', () {
      expect(AmountScaler.scale('3/4', 2), '1.5');
    });

    test('skaliert Bruch 1/2 × 0.5 = 0.25', () {
      expect(AmountScaler.scale('1/2', 0.5), '0.25');
    });

    // --- Nicht-skalierbare Texte ---
    test('lässt "nach Geschmack" unverändert', () {
      expect(AmountScaler.scale('nach Geschmack', 3), 'nach Geschmack');
    });

    test('lässt "etwas" unverändert', () {
      expect(AmountScaler.scale('etwas', 2), 'etwas');
    });

    test('lässt leere Zeichenkette unverändert', () {
      expect(AmountScaler.scale('', 2), '');
    });

    test('lässt "ca. 200" unverändert', () {
      expect(AmountScaler.scale('ca. 200', 2), 'ca. 200');
    });
  });

  group('Ingredient.scale()', () {
    test('skaliert amount korrekt', () {
      final ing = Ingredient(name: 'Mehl', unit: null, amount: '200');
      final scaled = ing.scale(2);
      expect(scaled.amount, '400');
    });

    test('amount null → Ingredient bleibt unverändert', () {
      final ing = Ingredient(name: 'Salz', unit: null, amount: null);
      final scaled = ing.scale(3);
      expect(scaled, same(ing));
    });

    test('behält name und unit nach Skalierung', () {
      final ing = Ingredient(name: 'Milch', unit: null, amount: '250');
      final scaled = ing.scale(2);
      expect(scaled.name, 'Milch');
      expect(scaled.unit, null);
      expect(scaled.amount, '500');
    });

    test('skaliert Bruch in amount', () {
      final ing = Ingredient(name: 'Butter', unit: null, amount: '1/2');
      final scaled = ing.scale(4);
      expect(scaled.amount, '2');
    });

    test('nicht-skalierbarer Text in amount bleibt unverändert', () {
      final ing =
          Ingredient(name: 'Pfeffer', unit: null, amount: 'nach Geschmack');
      final scaled = ing.scale(5);
      expect(scaled.amount, 'nach Geschmack');
    });

    test('Faktor 1.0 liefert identischen amount', () {
      final ing = Ingredient(name: 'Ei', unit: null, amount: '3');
      final scaled = ing.scale(1.0);
      expect(scaled.amount, '3');
    });
  });

  group('displayAmountAndUnit – Einheitenkonvertierung', () {
    test('1200 g → 1.2 kg', () {
      final ing = Ingredient(name: 'Mehl', unit: Unit.GRAMM, amount: '1200');
      expect(ing.displayAmountAndUnit, ('1.2', 'kg'));
    });

    test('1000 g → 1 kg', () {
      final ing = Ingredient(name: 'Zucker', unit: Unit.GRAMM, amount: '1000');
      expect(ing.displayAmountAndUnit, ('1', 'kg'));
    });

    test('2500 g → 2.5 kg', () {
      final ing = Ingredient(name: 'Mehl', unit: Unit.GRAMM, amount: '2500');
      expect(ing.displayAmountAndUnit, ('2.5', 'kg'));
    });

    test('1500 ml → 1.5 l', () {
      final ing = Ingredient(name: 'Wasser', unit: Unit.MILLILITER, amount: '1500');
      expect(ing.displayAmountAndUnit, ('1.5', 'l'));
    });

    test('1000 ml → 1 l', () {
      final ing = Ingredient(name: 'Milch', unit: Unit.MILLILITER, amount: '1000');
      expect(ing.displayAmountAndUnit, ('1', 'l'));
    });

    test('500 g bleibt 500 g', () {
      final ing = Ingredient(name: 'Butter', unit: Unit.GRAMM, amount: '500');
      expect(ing.displayAmountAndUnit, ('500', 'g'));
    });

    test('200 ml bleibt 200 ml', () {
      final ing = Ingredient(name: 'Sahne', unit: Unit.MILLILITER, amount: '200');
      expect(ing.displayAmountAndUnit, ('200', 'ml'));
    });

    test('andere Einheit wird nicht konvertiert', () {
      final ing = Ingredient(name: 'Salz', unit: Unit.TEASPOON, amount: '2000');
      expect(ing.displayAmountAndUnit, ('2000', 'TL'));
    });

    test('amount null → leerer String', () {
      final ing = Ingredient(name: 'Salz', unit: Unit.GRAMM, amount: null);
      expect(ing.displayAmountAndUnit, ('', 'g'));
    });

    test('nicht-parseable amount bleibt unverändert', () {
      final ing = Ingredient(name: 'Pfeffer', unit: Unit.GRAMM, amount: 'nach Geschmack');
      expect(ing.displayAmountAndUnit, ('nach Geschmack', 'g'));
    });
  });
}
