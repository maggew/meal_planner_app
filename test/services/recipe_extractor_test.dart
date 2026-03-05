import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/services/recipe_extractor.dart';

// ignore_for_file: invalid_use_of_visible_for_testing_member

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

  // ═══════════════════════════════════════════════════════════════════
  // Pipeline step: splitOnDelimiters
  // ═══════════════════════════════════════════════════════════════════
  group('splitOnDelimiters', () {
    test('splits on ♦', () {
      expect(
        RecipeExtractor.splitOnDelimiters(['200g Mehl ♦ 3 Eier']),
        ['200g Mehl', '3 Eier'],
      );
    });

    test('splits on •', () {
      expect(
        RecipeExtractor.splitOnDelimiters(['100ml Milch • 50g Butter']),
        ['100ml Milch', '50g Butter'],
      );
    });

    test('splits on ◆', () {
      expect(
        RecipeExtractor.splitOnDelimiters(['1 TL Salz ◆ 2 EL Öl']),
        ['1 TL Salz', '2 EL Öl'],
      );
    });

    test('line without delimiter passes through unchanged', () {
      expect(
        RecipeExtractor.splitOnDelimiters(['200g Mehl']),
        ['200g Mehl'],
      );
    });

    test('empty parts after split are discarded', () {
      final result = RecipeExtractor.splitOnDelimiters(['• 200g Mehl •']);
      expect(result, ['200g Mehl']);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // Pipeline step: normalizeLineSpacing
  // ═══════════════════════════════════════════════════════════════════
  group('normalizeLineSpacing', () {
    test('"40g" → "40 g"', () {
      expect(RecipeExtractor.normalizeLineSpacing('40g Mehl'), '40 g Mehl');
    });

    test('"1,2l" → "1,2 l"', () {
      expect(RecipeExtractor.normalizeLineSpacing('1,2l Wasser'), '1,2 l Wasser');
    });

    test('"abc)7" → "abc) 7"', () {
      expect(RecipeExtractor.normalizeLineSpacing('Bohnen (250g)7 EL'), 'Bohnen (250 g) 7 EL');
    });

    test('already-spaced line passes through unchanged', () {
      expect(RecipeExtractor.normalizeLineSpacing('200 g Mehl'), '200 g Mehl');
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // Pipeline step: mergeHyphenatedLines
  // ═══════════════════════════════════════════════════════════════════
  group('mergeHyphenatedLines', () {
    test('merges word- + lowercase continuation', () {
      expect(
        RecipeExtractor.mergeHyphenatedLines(['Vollkorn-', 'brot']),
        ['Vollkornbrot'],
      );
    });

    test('keeps hyphen when next line starts with uppercase', () {
      expect(
        RecipeExtractor.mergeHyphenatedLines(['Vollkornbrot-', 'Scheiben']),
        ['Vollkornbrot-Scheiben'],
      );
    });

    test('non-hyphenated lines pass through unchanged', () {
      expect(
        RecipeExtractor.mergeHyphenatedLines(['200 g Mehl', '3 Eier']),
        ['200 g Mehl', '3 Eier'],
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // Pipeline step: pairOrphanAmountsWithNames
  // ═══════════════════════════════════════════════════════════════════
  group('pairOrphanAmountsWithNames', () {
    test('pairs "3 EL" + "Rapsöl"', () {
      expect(
        RecipeExtractor.pairOrphanAmountsWithNames(['3 EL', 'Rapsöl']),
        ['3 EL Rapsöl'],
      );
    });

    test('complete line passes through immediately when queue is empty', () {
      expect(
        RecipeExtractor.pairOrphanAmountsWithNames(['200 g Mehl']),
        ['200 g Mehl'],
      );
    });

    test('quantityless ingredient (Salz) is never paired', () {
      final result = RecipeExtractor.pairOrphanAmountsWithNames(['1 TL', 'Salz']);
      expect(result, contains('Salz'));
      final salz = result.firstWhere((l) => l.contains('Salz'));
      expect(salz, isNot(contains('TL')));
    });

    test('parenthetical line is appended to previous', () {
      expect(
        RecipeExtractor.pairOrphanAmountsWithNames(['1,2 l Gemüsebrühe', '(ggf. glutenfrei)']),
        ['1,2 l Gemüsebrühe (ggf. glutenfrei)'],
      );
    });

    test('parenthetical as very first line is added directly to output', () {
      final result = RecipeExtractor.pairOrphanAmountsWithNames(['(optional)', '200 g Mehl']);
      expect(result, contains('(optional)'));
    });

    test('deferred complete line appears after its preceding pairs', () {
      // "3 EL" and "1 TL" precede "1 Dose", so "1 Dose" must come after both pairings
      final input = ['3 EL', '1 TL', '1 Dose Bohnen', 'Rapsöl', 'Curry'];
      final result = RecipeExtractor.pairOrphanAmountsWithNames(input);
      final rapsoeIdx = result.indexWhere((l) => l.contains('Rapsöl'));
      final curryIdx = result.indexWhere((l) => l.contains('Curry'));
      final bohnenIdx = result.indexWhere((l) => l.contains('Bohnen'));
      expect(bohnenIdx, greaterThan(curryIdx));
      expect(rapsoeIdx, lessThan(bohnenIdx));
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // Pipeline step: mergeContinuationLines
  // ═══════════════════════════════════════════════════════════════════
  group('mergeContinuationLines', () {
    test('appends "(glutenfrei)" to previous line', () {
      expect(
        RecipeExtractor.mergeContinuationLines(['1,2 l Gemüsebrühe', '(ggf. glutenfrei)']),
        ['1,2 l Gemüsebrühe (ggf. glutenfrei)'],
      );
    });

    test('non-continuation lines pass through unchanged', () {
      expect(
        RecipeExtractor.mergeContinuationLines(['200 g Mehl', '3 Eier']),
        ['200 g Mehl', '3 Eier'],
      );
    });

    test('lowercase continuation (not quantityless) is merged with previous', () {
      // "tomaten" starts lowercase and is not in _quantitylessIngredients
      expect(
        RecipeExtractor.mergeContinuationLines(['200 g Mehl', 'tomaten']),
        ['200 g Mehl tomaten'],
      );
    });

    test('flour type continuation ("Typ 550") is merged with previous', () {
      expect(
        RecipeExtractor.mergeContinuationLines(['200 g Mehl', 'Typ 550']),
        ['200 g Mehl Typ 550'],
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // Pipeline step: isSectionHeader
  // ═══════════════════════════════════════════════════════════════════
  group('isSectionHeader', () {
    test('"Für den Teig:" is a header', () {
      expect(RecipeExtractor.isSectionHeader('Für den Teig:'), isTrue);
    });

    test('"Marinade" is a header', () {
      expect(RecipeExtractor.isSectionHeader('Marinade'), isTrue);
    });

    test('"Butter" is NOT a header', () {
      expect(RecipeExtractor.isSectionHeader('Butter'), isFalse);
    });

    test('"200 g Mehl" is NOT a header (contains digit)', () {
      expect(RecipeExtractor.isSectionHeader('200 g Mehl'), isFalse);
    });

    test('"rucola" is NOT a header (lowercase start)', () {
      expect(RecipeExtractor.isSectionHeader('rucola'), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // Pipeline step: createSections
  // ═══════════════════════════════════════════════════════════════════
  group('createSections', () {
    test('single section without header uses "Zutaten"', () {
      final sections = RecipeExtractor.createSections(['200 g Mehl', '3 Eier']);
      expect(sections.keys, contains('Zutaten'));
      expect(sections['Zutaten'], ['200 g Mehl', '3 Eier']);
    });

    test('header splits into separate section', () {
      final sections = RecipeExtractor.createSections([
        'Für den Teig:',
        '200 g Mehl',
        'Füllung',
        '100 g Käse',
      ]);
      expect(sections.keys, containsAll(['Für den Teig', 'Füllung']));
      expect(sections['Für den Teig'], ['200 g Mehl']);
      expect(sections['Füllung'], ['100 g Käse']);
    });

    test('trailing colon is stripped from header name', () {
      final sections = RecipeExtractor.createSections(['Marinade:', '2 EL Öl']);
      expect(sections.keys, contains('Marinade'));
      expect(sections.keys, isNot(contains('Marinade:')));
    });

    test('"Header: inline content" creates section and adds inline item', () {
      // No digit in inline item — isSectionHeader rejects lines with digits
      final sections = RecipeExtractor.createSections([
        'Für die Soße: Backpapier',
        '1 TL Salz',
      ]);
      expect(sections.keys, contains('Für die Soße'));
      expect(sections['Für die Soße'], containsAll(['Backpapier', '1 TL Salz']));
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // Pipeline step: splitInlineIngredients — edge cases
  // ═══════════════════════════════════════════════════════════════════
  group('splitInlineIngredients – edge cases', () {
    test('inline section keyword splits via _inlineSectionPattern', () {
      // "marinade" is lowercase → only _inlineSectionPattern can fire here
      final result = RecipeExtractor.splitInlineIngredients(
          ['100g Mehl marinade: Käse']);
      expect(result.length, greaterThan(1));
      expect(result.first, contains('Mehl'));
      expect(result.last, contains('marinade'));
    });

    test('parenthesis before split point is traversed (depth++)', () {
      // "(Bio)" contains "(" which increments depth; after ")" depth is 0 again
      // so "3 EL" after the paren is still split correctly
      final result = RecipeExtractor.splitInlineIngredients(
          ['200g Mehl (Bio) 3 EL Öl']);
      expect(result, ['200g Mehl (Bio)', '3 EL Öl']);
    });

    test('match inside parentheses is NOT split (depth > 0)', () {
      // "3 EL" is inside parens → must NOT be split
      final result = RecipeExtractor.splitInlineIngredients(
          ['200g Mehl (3 EL Öl)']);
      expect(result, ['200g Mehl (3 EL Öl)']);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // ExtractionResult constructor
  // ═══════════════════════════════════════════════════════════════════
  group('ExtractionResult', () {
    test('stores ingredientSections', () {
      final result = ExtractionResult(ingredientSections: []);
      expect(result.ingredientSections, isEmpty);
      expect(result.instructions, isNull);
    });

    test('stores instructions', () {
      final result = ExtractionResult(instructions: 'Schritt 1: Backen.');
      expect(result.instructions, 'Schritt 1: Backen.');
      expect(result.ingredientSections, isNull);
    });

    test('default constructor has all fields null', () {
      final result = ExtractionResult();
      expect(result.ingredientSections, isNull);
      expect(result.instructions, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // parseAmountToken
  // ═══════════════════════════════════════════════════════════════════
  group('parseAmountToken', () {
    test('integer returns as-is', () {
      expect(RecipeExtractor.parseAmountToken('150'), '150');
    });

    test('decimal (dot) returns as-is', () {
      expect(RecipeExtractor.parseAmountToken('1.5'), '1.5');
    });

    test('decimal (comma) is normalised to dot', () {
      expect(RecipeExtractor.parseAmountToken('1,5'), '1.5');
    });

    test('fraction returns as-is', () {
      expect(RecipeExtractor.parseAmountToken('1/2'), '1/2');
    });

    test('range without spaces returns as-is', () {
      expect(RecipeExtractor.parseAmountToken('150-200'), '150-200');
    });

    test('range with spaces has spaces removed', () {
      // "150 - 200" matches the range regex; replaceAll strips the spaces
      expect(RecipeExtractor.parseAmountToken('150 - 200'), '150-200');
    });

    test('en-dash range with spaces has spaces removed', () {
      expect(RecipeExtractor.parseAmountToken('150 – 200'), '150–200');
    });

    test('non-numeric token returns null', () {
      expect(RecipeExtractor.parseAmountToken('Mehl'), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // normalizeIngredientText
  // ═══════════════════════════════════════════════════════════════════
  group('normalizeIngredientText', () {
    test('½ is replaced with 1/2', () {
      expect(RecipeExtractor.normalizeIngredientText('½ EL Öl'), '1/2 EL Öl');
    });

    test('¼ is replaced with 1/4', () {
      expect(RecipeExtractor.normalizeIngredientText('¼ TL Salz'), '1/4 TL Salz');
    });

    test('number+unit without space gets a space inserted (first replaceAllMapped)', () {
      // e.g. "200g" → "200 g" via the digit+unit pattern
      expect(RecipeExtractor.normalizeIngredientText('200g Mehl'), '200 g Mehl');
    });

    test('number+uppercase-letter without space gets a space inserted (second replaceAllMapped)', () {
      // "3Äpfel": "Ä" is not a unit abbreviation, so only the second replaceAllMapped fires
      expect(RecipeExtractor.normalizeIngredientText('3Äpfel'), '3 Äpfel');
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // assembleNumberedSteps
  // ═══════════════════════════════════════════════════════════════════
  group('assembleNumberedSteps', () {
    // ── korrekte Fälle (aktuell grün) ──────────────────────────────

    test('einfache nummerierte Schritte mit Punkt', () {
      final result = RecipeExtractor.assembleNumberedSteps([
        '1. Zwiebeln würfeln.',
        '2. In Öl anschwitzen.',
        '3. Salzen.',
      ]);
      expect(result, '1. Zwiebeln würfeln.\n\n2. In Öl anschwitzen.\n\n3. Salzen.');
    });

    test('Trennzeichen Doppelpunkt', () {
      final result = RecipeExtractor.assembleNumberedSteps([
        '1: Teig kneten.',
        '2: Ruhen lassen.',
      ]);
      expect(result, '1. Teig kneten.\n\n2. Ruhen lassen.');
    });

    test('Trennzeichen Klammer', () {
      final result = RecipeExtractor.assembleNumberedSteps([
        '1) Teig kneten.',
        '2) Backen.',
      ]);
      expect(result, '1. Teig kneten.\n\n2. Backen.');
    });

    test('Trennzeichen Bindestrich', () {
      final result = RecipeExtractor.assembleNumberedSteps([
        '1- Teig kneten.',
        '2- Backen.',
      ]);
      expect(result, '1. Teig kneten.\n\n2. Backen.');
    });

    test('Continuation-Zeilen werden an aktuellen Schritt angehängt', () {
      final result = RecipeExtractor.assembleNumberedSteps([
        '1. Teig kneten.',
        'Dabei 10 Minuten arbeiten.',
        '2. Backen.',
      ]);
      expect(result, '1. Teig kneten. Dabei 10 Minuten arbeiten.\n\n2. Backen.');
    });

    test('Schritte werden sortiert auch wenn OCR sie ungeordnet liefert', () {
      final result = RecipeExtractor.assembleNumberedSteps([
        '3. Backen.',
        '1. Teig kneten.',
        '2. Ruhen lassen.',
      ]);
      expect(result, '1. Teig kneten.\n\n2. Ruhen lassen.\n\n3. Backen.');
    });

    test('doppelte Schrittnummer (OCR-Artefakt) wird zusammengeführt', () {
      final result = RecipeExtractor.assembleNumberedSteps([
        '1. Erste Hälfte.',
        '1. Zweite Hälfte.',
        '2. Nächster Schritt.',
      ]);
      expect(result, '1. Erste Hälfte. Zweite Hälfte.\n\n2. Nächster Schritt.');
    });

    // ── Bugs (aktuell rot) ──────────────────────────────────────────

    test('Schrittnummer allein auf Zeile: Inhalt folgt in nächster Zeile', () {
      // "1." allein → kein Match auf stepPattern → currentStep bleibt null
      // → Folgezeile geht verloren (Bug 1)
      final result = RecipeExtractor.assembleNumberedSteps([
        '1.',
        'Zwiebeln würfeln.',
        '2.',
        'In Öl anschwitzen.',
      ]);
      expect(result, '1. Zwiebeln würfeln.\n\n2. In Öl anschwitzen.');
    });

    test('kein nummerierter Schritt: Zeilenstruktur bleibt erhalten', () {
      // Fallback join(' ') verliert Zeilenumbrüche (Bug 2)
      final result = RecipeExtractor.assembleNumberedSteps([
        'Zwiebeln würfeln.',
        'In Öl anschwitzen.',
        'Mit Salz abschmecken.',
      ]);
      expect(result, 'Zwiebeln würfeln.\nIn Öl anschwitzen.\nMit Salz abschmecken.');
    });

    test('Mengenangabe mit Punkt wird nicht als Schrittnummer erkannt', () {
      // "2. EL Öl erhitzen" → stepPattern matcht fälschlich (Bug 3)
      // → soll als eine einzige Continuation-Zeile durchgehen
      final result = RecipeExtractor.assembleNumberedSteps([
        '1. Öl erhitzen.',
        '2. EL Butter zugeben.',
        '3. Rühren.',
      ]);
      // "2. EL Butter zugeben." ist eine Mengenangabe, kein Schritt
      expect(result, '1. Öl erhitzen. 2. EL Butter zugeben.\n\n3. Rühren.');
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // _parseIngredientLine – branch: non-numeric first token + valid unit second token
  // ═══════════════════════════════════════════════════════════════════
  group('parseIngredientLine via processRawLines', () {
    test('line with non-numeric first token followed by unit is parsed', () {
      // "x EL Öl": first token "x" is not a valid amount, second "EL" is a unit
      // → branch: amount=tokens.first, unit=EL, name="Öl"
      final sections = RecipeExtractor.processRawLines(['x EL Öl']);
      final ing = _find(sections, 'Öl');
      expect(ing.unit, Unit.EATINGSPOON);
      expect(ing.amount, 'x');
    });
  });
}
