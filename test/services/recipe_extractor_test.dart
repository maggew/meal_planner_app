import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/services/recipe_extractor.dart';

// Hilfsfunktion: findet die erste Zutat, deren Name [query] enthält
Ingredient _find(List<IngredientSection> sections, String query) {
  for (final section in sections) {
    for (final ing in section.ingredients) {
      if (ing.name.toLowerCase().contains(query.toLowerCase())) return ing;
    }
  }
  throw Exception('Zutat "$query" nicht gefunden');
}

void main() {
  // ═══════════════════════════════════════════════════════════════════
  // Tabellarisches Format
  // Simuliert OCR-Output wenn Amount-Spalte und Name-Spalte getrennt
  // erkannt werden (Column-Clustering trennt links von rechts).
  // ═══════════════════════════════════════════════════════════════════
  group('RecipeExtractor – tabellarisches Format (orphan pairing)', () {
    // Entspricht dem tatsächlichen Debug-Output aus dem Lauch-Rezept
    final tabularLines = [
      '600g Lauch',
      '3 EL',
      '1 TL',
      '1 Dose weiße Bohnen (250 g)',
      '1,2l',
      '2',
      'Rapsöl',
      'Curry (gemahlen)',
      'Gemüsebrühe',
      '(ggf. glutenfrei)',
      'rote Äpfel',
      '1 EL',
      '1TL Zucker',
      '200g Sojacreme Cuisine',
      '4',
      'Zitronensaft',
      'Salz',
      'Pfeffer',
      'Vollkornbrot-',
      'Scheiben',
    ];

    late List<IngredientSection> sections;
    setUp(() => sections = RecipeExtractor.processRawLines(tabularLines));

    test('ergibt genau eine Sektion', () {
      expect(sections.length, 1);
    });

    test('vollständige Zeile "600g Lauch" bleibt korrekt', () {
      final ing = _find(sections, 'Lauch');
      expect(ing.amount, '600');
      expect(ing.unit, Unit.GRAMM);
    });

    test('"3 EL" + "Rapsöl" werden gepaart', () {
      final ing = _find(sections, 'Rapsöl');
      expect(ing.amount, '3');
      expect(ing.unit, Unit.EATINGSPOON);
    });

    test('"1 TL" + "Curry (gemahlen)" werden gepaart', () {
      final ing = _find(sections, 'Curry');
      expect(ing.amount, '1');
      expect(ing.unit, Unit.TEASPOON);
    });

    test('"1 Dose" + "weiße Bohnen" (vollständig) bleibt unverändert', () {
      final ing = _find(sections, 'Bohnen');
      expect(ing.amount, '1');
      expect(ing.unit, Unit.CAN);
    });

    test('"1,2 l" + "Gemüsebrühe" werden gepaart', () {
      final ing = _find(sections, 'Gemüsebrühe');
      expect(ing.amount, '1.2');
      expect(ing.unit, Unit.LITER);
    });

    test('"(ggf. glutenfrei)" wird an Gemüsebrühe angehängt', () {
      final ing = _find(sections, 'Gemüsebrühe');
      expect(ing.name, contains('glutenfrei'));
    });

    test('"2" + "rote Äpfel" (Name mit Kleinbuchstabe) werden gepaart', () {
      final ing = _find(sections, 'Äpfel');
      expect(ing.amount, '2');
    });

    test('"1 EL" + "Zitronensaft" werden gepaart', () {
      final ing = _find(sections, 'Zitronensaft');
      expect(ing.amount, '1');
      expect(ing.unit, Unit.EATINGSPOON);
    });

    test('"1TL Zucker" (vollständig) bleibt unverändert', () {
      final ing = _find(sections, 'Zucker');
      expect(ing.amount, '1');
      expect(ing.unit, Unit.TEASPOON);
    });

    test('"200g Sojacreme Cuisine" (vollständig) bleibt unverändert', () {
      final ing = _find(sections, 'Sojacreme');
      expect(ing.amount, '200');
      expect(ing.unit, Unit.GRAMM);
    });

    test('Salz wird nicht mit orphan amount gepaart (quantityless)', () {
      final ing = _find(sections, 'Salz');
      expect(ing.amount, isNull);
    });

    test('Pfeffer wird nicht mit orphan amount gepaart (quantityless)', () {
      final ing = _find(sections, 'Pfeffer');
      expect(ing.amount, isNull);
    });

    test('"4" + "Vollkornbrot-Scheiben" (Bindestrich gemergt) werden gepaart', () {
      final ing = _find(sections, 'Vollkornbrot');
      expect(ing.amount, '4');
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // Fließtext-Format — Rückwärtskompatibilität sicherstellen
  // ═══════════════════════════════════════════════════════════════════
  group('RecipeExtractor – Fließtext-Format (Rückwärtskompatibilität)', () {
    final fliesstext = [
      '800g dunkle kernlose Weintrauben (s. Tipp) • 7 EL Bratöl',
      '4 EL heller Balsamico-Essig 3 EL Rohrohrzucker',
      '200 g rote Zwiebeln 3 Knoblauchzehen 80 g Rucola',
    ];

    late List<IngredientSection> sections;
    setUp(() => sections = RecipeExtractor.processRawLines(fliesstext));

    test('Weintrauben korrekt erkannt', () {
      final ing = _find(sections, 'Weintrauben');
      expect(ing.amount, '800');
      expect(ing.unit, Unit.GRAMM);
    });

    test('Bratöl (nach •) korrekt erkannt', () {
      final ing = _find(sections, 'Bratöl');
      expect(ing.amount, '7');
      expect(ing.unit, Unit.EATINGSPOON);
    });

    test('Balsamico korrekt erkannt', () {
      final ing = _find(sections, 'Balsamico');
      expect(ing.amount, '4');
      expect(ing.unit, Unit.EATINGSPOON);
    });

    test('Zwiebeln korrekt erkannt', () {
      final ing = _find(sections, 'Zwiebeln');
      expect(ing.amount, '200');
      expect(ing.unit, Unit.GRAMM);
    });

    test('Rucola korrekt erkannt', () {
      final ing = _find(sections, 'Rucola');
      expect(ing.amount, '80');
      expect(ing.unit, Unit.GRAMM);
    });
  });
}
