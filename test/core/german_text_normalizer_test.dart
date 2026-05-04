import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/utils/german_text_normalizer.dart';

void main() {
  group('GermanTextNormalizer.normalizeSimple', () {
    test('konvertiert Umlaute', () {
      expect(GermanTextNormalizer.normalizeSimple('Äpfel'), 'aepfel');
      expect(GermanTextNormalizer.normalizeSimple('Öl'), 'oel');
      expect(GermanTextNormalizer.normalizeSimple('Süßkartoffel'), 'suesskartoffel');
    });

    test('macht lowercase', () {
      expect(GermanTextNormalizer.normalizeSimple('TOMATE'), 'tomate');
    });

    test('strippt keine Suffixe — Plural bleibt erhalten', () {
      expect(GermanTextNormalizer.normalizeSimple('Tomaten'), 'tomaten');
      expect(GermanTextNormalizer.normalizeSimple('Nudeln'), 'nudeln');
    });
  });

  group('GermanTextNormalizer.normalize (mit Suffix-Stripping)', () {
    test('strippt -en: Tomaten → tomat', () {
      expect(GermanTextNormalizer.normalize('Tomaten'), 'tomat');
    });

    test('strippt -n: Nudeln → nudel', () {
      expect(GermanTextNormalizer.normalize('Nudeln'), 'nudel');
    });

    test('strippt -e: Tomate → tomat', () {
      expect(GermanTextNormalizer.normalize('Tomate'), 'tomat');
    });

    test('strippt -n: Zwiebeln → zwiebel, Singular Zwiebel bleibt zwiebel', () {
      expect(GermanTextNormalizer.normalize('Zwiebeln'), 'zwiebel');
      expect(GermanTextNormalizer.normalize('Zwiebel'), 'zwiebel');
    });

    test('strippt -es: Käses → kaes', () {
      expect(GermanTextNormalizer.normalize('Käses'), 'kaes');
    });

    test('strippt -s: Salats → salat', () {
      expect(GermanTextNormalizer.normalize('Salats'), 'salat');
    });

    test('strippt -ung: Mischung → misch', () {
      expect(GermanTextNormalizer.normalize('Mischung'), 'misch');
    });

    test('strippt -ungen: Mischungen → misch', () {
      expect(GermanTextNormalizer.normalize('Mischungen'), 'misch');
    });

    test('kein Strip wenn Ergebnis kürzer als 3 Zeichen wäre', () {
      // "Ei" → keine -i Strip da zu kurz nach Strip
      expect(GermanTextNormalizer.normalize('Ei'), 'ei');
    });

    test('nur EIN Suffix wird gestrippt', () {
      // "Tomaten" endet auf -en → "tomat", nicht nochmal auf -at
      expect(GermanTextNormalizer.normalize('Tomaten'), 'tomat');
      expect(GermanTextNormalizer.normalize('Tomaten'), isNot('tom'));
    });

    test('konvertiert Umlaute vor dem Strip', () {
      expect(GermanTextNormalizer.normalize('Möhren'), 'moehr');
    });
  });

  group('GermanTextNormalizer.fuzzyMatch', () {
    test('exakter Match', () {
      expect(GermanTextNormalizer.fuzzyMatch('Tomate', 'Tomate'), true);
    });

    test('Plural-Needle gegen Singular-Haystack: Tomaten → Tomate', () {
      // normalize("Tomaten") = "tomat", normalize("Tomate") = "tomat"
      expect(GermanTextNormalizer.fuzzyMatch('Tomaten', 'Tomate'), true);
    });

    test('Singular-Needle gegen Plural-Haystack: Tomate → Tomaten', () {
      // normalize("Tomate") = "tomat", normalize("Tomaten") = "tomat"
      expect(GermanTextNormalizer.fuzzyMatch('Tomate', 'Tomaten'), true);
    });

    test('Umlaut + Plural: Möhren findet Möhre', () {
      expect(GermanTextNormalizer.fuzzyMatch('Möhren', 'Möhre'), true);
    });

    test('case-insensitiv', () {
      expect(GermanTextNormalizer.fuzzyMatch('TOMATE', 'tomate'), true);
    });

    test('kein Match bei anderem Wort', () {
      expect(GermanTextNormalizer.fuzzyMatch('Karotte', 'Tomate'), false);
    });

    test('Ingredient-Substring: Nudeln matcht Spaghetti Nudeln', () {
      expect(GermanTextNormalizer.fuzzyMatch('Nudeln', 'Spaghetti Nudeln'), true);
    });

    // Bugs behoben durch Token-Präfix-Matching
    test('Tomate matcht Automat nicht (false positive behoben)', () {
      expect(GermanTextNormalizer.fuzzyMatch('Tomate', 'Automat'), false);
    });

    test('Ei matcht Reis nicht (false positive behoben)', () {
      expect(GermanTextNormalizer.fuzzyMatch('Ei', 'Reis'), false);
    });

    // Kern-Bug: Lauch darf Knoblauch nicht matchen
    test('Lauch matcht Knoblauch nicht', () {
      expect(GermanTextNormalizer.fuzzyMatch('Lauch', 'Knoblauch'), false);
    });

    // Präfix-Matching auf Tokens
    test('Lauch matcht Lauchzwiebeln (Präfix auf Token)', () {
      expect(GermanTextNormalizer.fuzzyMatch('Lauch', 'Lauchzwiebeln'), true);
    });

    test('Lauch matcht Frischer Lauch (Token nach Leerzeichen)', () {
      expect(GermanTextNormalizer.fuzzyMatch('Lauch', 'Frischer Lauch'), true);
    });

    test('Lauch matcht Lauch, gewürfelt (Token vor Komma)', () {
      expect(GermanTextNormalizer.fuzzyMatch('Lauch', 'Lauch, gewürfelt'), true);
    });

    test('Lauch matcht Lauch-Rüebli (Token vor Bindestrich)', () {
      expect(GermanTextNormalizer.fuzzyMatch('Lauch', 'Lauch-Rüebli'), true);
    });

    test('Petersilie matcht Petersilie/Koriander (Token vor Slash)', () {
      expect(GermanTextNormalizer.fuzzyMatch('Petersilie', 'Petersilie/Koriander'), true);
    });
  });
}
