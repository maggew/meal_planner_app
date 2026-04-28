import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/carb_tag.dart';
import 'package:meal_planner/domain/services/carb_tag_detector.dart';

void main() {
  IngredientSection section(List<String> names) => IngredientSection(
        title: 'Zutaten',
        ingredients:
            names.map((n) => Ingredient(name: n, unit: null, amount: null)).toList(),
      );

  // ==================== detect() — Keyword-Varianten ====================

  group('CarbTagDetector.detect — Reis-Varianten', () {
    test('Risotto → reis', () {
      expect(CarbTagDetector.detect([section(['Risotto', 'Parmesan'])]),
          contains(CarbTag.reis));
    });

    test('Reismehl → reis', () {
      expect(CarbTagDetector.detect([section(['Reismehl', 'Wasser'])]),
          contains(CarbTag.reis));
    });

    test('Reisweinessig → kein reis (Kondiment, kein KH)', () {
      final tags = CarbTagDetector.detect([section(['Reisweinessig', 'Sesamöl', 'Tofu'])]);
      expect(tags, isNot(contains(CarbTag.reis)));
    });

    test('Reisessig → kein reis (Kondiment, kein KH)', () {
      final tags = CarbTagDetector.detect([section(['Reisessig', 'Ingwer'])]);
      expect(tags, isNot(contains(CarbTag.reis)));
    });

    test('Reisweinessig neben echtem Reis → reis wird trotzdem erkannt', () {
      final tags = CarbTagDetector.detect([section(['Reisweinessig', '200 g Reis'])]);
      expect(tags, contains(CarbTag.reis));
    });
  });

  group('CarbTagDetector.detect — Pasta-Varianten', () {
    test('Gnocchi → pasta', () {
      expect(CarbTagDetector.detect([section(['Gnocchi', 'Tomaten'])]),
          contains(CarbTag.pasta));
    });

    test('Tortellini → pasta', () {
      expect(CarbTagDetector.detect([section(['Tortellini', 'Sahne'])]),
          contains(CarbTag.pasta));
    });

    test('Lasagne → pasta', () {
      expect(CarbTagDetector.detect([section(['Lasagneblätter', 'Hackfleisch'])]),
          contains(CarbTag.pasta));
    });

    test('Penne → pasta', () {
      expect(CarbTagDetector.detect([section(['Penne', 'Pesto'])]),
          contains(CarbTag.pasta));
    });
  });

  group('CarbTagDetector.detect — Kartoffel-Varianten', () {
    test('Pommes → kartoffel', () {
      expect(CarbTagDetector.detect([section(['Pommes', 'Ketchup'])]),
          contains(CarbTag.kartoffel));
    });

    test('Püree → kartoffel', () {
      expect(CarbTagDetector.detect([section(['Kartoffelpüree', 'Butter'])]),
          contains(CarbTag.kartoffel));
    });

    test('Süßkartoffeln (Umlaut + ß + Plural) → kartoffel', () {
      expect(CarbTagDetector.detect([section(['Süßkartoffeln', 'Olivenöl'])]),
          contains(CarbTag.kartoffel));
    });

    test('Bratkartoffeln → kartoffel', () {
      expect(CarbTagDetector.detect([section(['Bratkartoffeln', 'Zwiebeln'])]),
          contains(CarbTag.kartoffel));
    });

    test('Knödel → kartoffel', () {
      expect(CarbTagDetector.detect([section(['Knödel', 'Butter'])]),
          contains(CarbTag.kartoffel));
    });
  });

  group('CarbTagDetector.detect — Brot-Varianten', () {
    test('Toast → brot', () {
      expect(CarbTagDetector.detect([section(['Toastbrot', 'Käse'])]),
          contains(CarbTag.brot));
    });

    test('Baguette → brot', () {
      expect(CarbTagDetector.detect([section(['Baguette', 'Butter'])]),
          contains(CarbTag.brot));
    });

    test('Wrap → brot', () {
      expect(CarbTagDetector.detect([section(['Wraps', 'Hähnchen'])]),
          contains(CarbTag.brot));
    });

    test('Tortilla → brot', () {
      expect(CarbTagDetector.detect([section(['Tortillas', 'Salsa'])]),
          contains(CarbTag.brot));
    });

    test('Pita → brot', () {
      expect(CarbTagDetector.detect([section(['Pitabrot', 'Hummus'])]),
          contains(CarbTag.brot));
    });
  });

  group('CarbTagDetector.detect — Couscous/Bulgur-Varianten', () {
    test('Bulgur → couscousBulgur', () {
      expect(CarbTagDetector.detect([section(['Bulgur', 'Tomaten'])]),
          contains(CarbTag.couscousBulgur));
    });

    test('Quinoa → couscousBulgur', () {
      expect(CarbTagDetector.detect([section(['Quinoa', 'Gemüse'])]),
          contains(CarbTag.couscousBulgur));
    });

    test('Hirse → couscousBulgur', () {
      expect(CarbTagDetector.detect([section(['Hirse', 'Gemüsebrühe'])]),
          contains(CarbTag.couscousBulgur));
    });

    test('Grieß (Umlaut + ß) → couscousBulgur', () {
      expect(CarbTagDetector.detect([section(['Grieß', 'Milch'])]),
          contains(CarbTag.couscousBulgur));
    });
  });

  // ==================== detect() — Sonderfälle ====================

  group('CarbTagDetector.detect — Sonderfälle', () {
    test('Großbuchstaben: SPAGHETTI → pasta', () {
      expect(CarbTagDetector.detect([section(['SPAGHETTI', 'TOMATEN'])]),
          contains(CarbTag.pasta));
    });

    test('Compound-Wort: Kartoffelsuppe → kartoffel', () {
      expect(CarbTagDetector.detect([section(['Kartoffelsuppe', 'Sahne'])]),
          contains(CarbTag.kartoffel));
    });

    test('Compound-Wort: Nudelsuppe → pasta', () {
      expect(CarbTagDetector.detect([section(['Nudelsuppe', 'Gemüse'])]),
          contains(CarbTag.pasta));
    });

    test('Compound-Wort: Reissalat → reis', () {
      expect(CarbTagDetector.detect([section(['Reissalat', 'Paprika'])]),
          contains(CarbTag.reis));
    });

    test('Zutaten über mehrere Sections verteilt', () {
      final tags = CarbTagDetector.detect([
        section(['Hähnchenbrust', 'Zwiebeln']),
        section(['Nudeln', 'Tomaten']),
      ]);
      expect(tags, contains(CarbTag.pasta));
      expect(tags, isNot(contains(CarbTag.keine)));
    });

    test('mehrere Sections, keine KH → keine', () {
      final tags = CarbTagDetector.detect([
        section(['Hähnchenbrust']),
        section(['Salat', 'Olivenöl']),
      ]);
      expect(tags, [CarbTag.keine]);
    });
  });

  // ==================== detectFromNames() ====================

  group('CarbTagDetector.detectFromNames', () {
    test('leere Liste → keine', () {
      expect(CarbTagDetector.detectFromNames([]), [CarbTag.keine]);
    });

    test('["Nudeln"] → pasta', () {
      expect(CarbTagDetector.detectFromNames(['Nudeln']), contains(CarbTag.pasta));
    });

    test('["Reis", "Pasta"] → beide Tags', () {
      final tags = CarbTagDetector.detectFromNames(['Reis', 'Pasta']);
      expect(tags, containsAll([CarbTag.reis, CarbTag.pasta]));
    });

    test('["Salz", "Pfeffer"] → keine', () {
      expect(CarbTagDetector.detectFromNames(['Salz', 'Pfeffer']), [CarbTag.keine]);
    });

    test('Gleiches Verhalten wie detect() für einzelne Zutat', () {
      final fromSection =
          CarbTagDetector.detect([section(['Couscous', 'Gemüse'])]);
      final fromNames = CarbTagDetector.detectFromNames(['Couscous', 'Gemüse']);
      expect(fromNames, containsAll(fromSection));
    });
  });
}
