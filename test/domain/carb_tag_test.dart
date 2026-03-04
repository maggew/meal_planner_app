import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/utils/german_text_normalizer.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/carb_tag.dart';
import 'package:meal_planner/domain/services/carb_tag_detector.dart';
import 'package:meal_planner/domain/services/recipe_suggestion_service.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/recipe_suggestion.dart';

void main() {
  // ==================== GermanTextNormalizer ====================

  group('GermanTextNormalizer', () {
    test('konvertiert Umlaute', () {
      expect(GermanTextNormalizer.normalize('Nudeln'), 'nudel');
      expect(GermanTextNormalizer.normalize('Äpfel'), 'aepfel');
      expect(GermanTextNormalizer.normalize('Öl'), 'oel');
      expect(GermanTextNormalizer.normalize('Süße'), 'suess');
    });

    test('fuzzyMatch findet Substring', () {
      expect(GermanTextNormalizer.fuzzyMatch('nudel', 'Spaghetti Nudeln'), true);
      expect(GermanTextNormalizer.fuzzyMatch('kartoffel', 'Bratkartoffeln'), true);
      expect(GermanTextNormalizer.fuzzyMatch('reis', 'Basmatireis'), true);
    });

    test('fuzzyMatch schlägt fehl bei keinem Match', () {
      expect(GermanTextNormalizer.fuzzyMatch('pasta', 'Kartoffeln'), false);
      expect(GermanTextNormalizer.fuzzyMatch('brot', 'Reis'), false);
    });
  });

  // ==================== CarbTagDetector ====================

  group('CarbTagDetector', () {
    IngredientSection _section(List<String> names) => IngredientSection(
          title: 'Zutaten',
          ingredients: names
              .map((n) => Ingredient(name: n, unit: null, amount: null))
              .toList(),
        );

    test('erkennt Reis', () {
      final tags = CarbTagDetector.detect([_section(['Basmatireis', 'Wasser'])]);
      expect(tags, contains(CarbTag.reis));
    });

    test('erkennt Pasta', () {
      final tags = CarbTagDetector.detect([_section(['Spaghetti', 'Tomaten'])]);
      expect(tags, contains(CarbTag.pasta));
    });

    test('erkennt Kartoffel', () {
      final tags = CarbTagDetector.detect([_section(['Kartoffeln', 'Butter'])]);
      expect(tags, contains(CarbTag.kartoffel));
    });

    test('erkennt Brot', () {
      final tags = CarbTagDetector.detect([_section(['Brötchen', 'Käse'])]);
      expect(tags, contains(CarbTag.brot));
    });

    test('erkennt Couscous/Bulgur', () {
      final tags = CarbTagDetector.detect([_section(['Couscous', 'Gemüse'])]);
      expect(tags, contains(CarbTag.couscousBulgur));
    });

    test('gibt keine zurück wenn keine KH-Zutaten', () {
      final tags = CarbTagDetector.detect([_section(['Hühnerbrust', 'Salat'])]);
      expect(tags, [CarbTag.keine]);
    });

    test('erkennt mehrere Tags gleichzeitig', () {
      final tags = CarbTagDetector.detect([
        _section(['Spaghetti', 'Brot', 'Tomaten'])
      ]);
      expect(tags, containsAll([CarbTag.pasta, CarbTag.brot]));
    });

    test('leere Zutaten → keine', () {
      final tags = CarbTagDetector.detect([]);
      expect(tags, [CarbTag.keine]);
    });

    test('Getreide ist kein false positive für Reis', () {
      final tags = CarbTagDetector.detect([_section(['Getreide', 'Milch'])]);
      expect(tags, isNot(contains(CarbTag.reis)));
    });

    test('Reisessig wird korrekt als Reis erkannt', () {
      final tags = CarbTagDetector.detect([_section(['Reisessig', 'Gemüse'])]);
      expect(tags, contains(CarbTag.reis));
    });
  });

  // ==================== CarbTag Enum ====================

  group('CarbTag enum', () {
    test('fromValue round-trip', () {
      for (final tag in CarbTag.values) {
        expect(CarbTag.fromValue(tag.value), tag);
      }
    });

    test('fromValue unbekannter Wert → keine', () {
      expect(CarbTag.fromValue('xyz'), CarbTag.keine);
    });

    test('displayName ist nicht leer', () {
      for (final tag in CarbTag.values) {
        expect(tag.displayName.isNotEmpty, true);
      }
    });
  });

  // ==================== RecipeSuggestionService ====================

  group('RecipeSuggestionService', () {
    Recipe _recipe({
      required String id,
      required String name,
      List<String> carbTags = const [],
      List<IngredientSection> sections = const [],
    }) =>
        Recipe(
          id: id,
          name: name,
          categories: [],
          portions: 2,
          ingredientSections: sections,
          instructions: '',
          carbTags: carbTags,
        );

    IngredientSection _section(List<String> names) => IngredientSection(
          title: 'Zutaten',
          ingredients: names
              .map((n) => Ingredient(name: n, unit: null, amount: null))
              .toList(),
        );

    test('perfect match wenn alle Zutaten vorhanden', () {
      final recipe = _recipe(
        id: 'r1',
        name: 'Pasta',
        sections: [_section(['Nudeln', 'Tomaten'])],
      );
      final results = RecipeSuggestionService.suggest(
        recipes: [recipe],
        inputIngredients: ['Nudeln', 'Tomaten'],
        lastCookedMap: {},
        recentCarbTags: [],
      );
      expect(results.first.matchQuality, MatchQuality.perfect);
      expect(results.first.matchedIngredientCount, 2);
    });

    test('partial match wenn nur ein Teil der Zutaten vorhanden', () {
      final recipe = _recipe(
        id: 'r1',
        name: 'Pasta',
        sections: [_section(['Nudeln', 'Tomaten', 'Käse'])],
      );
      final results = RecipeSuggestionService.suggest(
        recipes: [recipe],
        inputIngredients: ['Nudeln', 'Zwiebeln'],
        lastCookedMap: {},
        recentCarbTags: [],
      );
      expect(results.first.matchQuality, MatchQuality.partial);
      expect(results.first.matchedIngredientCount, 1);
    });

    test('other wenn keine Zutat matched', () {
      final recipe = _recipe(
        id: 'r1',
        name: 'Pasta',
        sections: [_section(['Nudeln', 'Tomaten'])],
      );
      final results = RecipeSuggestionService.suggest(
        recipes: [recipe],
        inputIngredients: ['Reis', 'Kartoffeln'],
        lastCookedMap: {},
        recentCarbTags: [],
      );
      expect(results.first.matchQuality, MatchQuality.other);
    });

    test('keine Eingabe → other + ingredientScore 0.5', () {
      final recipe = _recipe(id: 'r1', name: 'Test');
      final results = RecipeSuggestionService.suggest(
        recipes: [recipe],
        inputIngredients: [],
        lastCookedMap: {},
        recentCarbTags: [],
      );
      expect(results.first.matchQuality, MatchQuality.other);
      expect(results.first.ingredientScore, 0.5);
    });

    test('rotationScore = 1.0 wenn Rezept nie gekocht', () {
      final recipe = _recipe(id: 'r1', name: 'Test');
      final results = RecipeSuggestionService.suggest(
        recipes: [recipe],
        inputIngredients: [],
        lastCookedMap: {},
        recentCarbTags: [],
      );
      expect(results.first.rotationScore, 1.0);
    });

    test('rotationScore = 0.0 wenn heute gekocht', () {
      final recipe = _recipe(id: 'r1', name: 'Test');
      final results = RecipeSuggestionService.suggest(
        recipes: [recipe],
        inputIngredients: [],
        lastCookedMap: {'r1': 0},
        recentCarbTags: [],
      );
      expect(results.first.rotationScore, 0.0);
    });

    test('rotationScore = 1.0 wenn vor 14+ Tagen gekocht', () {
      final recipe = _recipe(id: 'r1', name: 'Test');
      final results = RecipeSuggestionService.suggest(
        recipes: [recipe],
        inputIngredients: [],
        lastCookedMap: {'r1': 14},
        recentCarbTags: [],
      );
      expect(results.first.rotationScore, 1.0);
    });

    test('carbVarietyScore = 1.0 wenn keine Überlappung', () {
      final recipe = _recipe(id: 'r1', name: 'Test', carbTags: ['reis']);
      final results = RecipeSuggestionService.suggest(
        recipes: [recipe],
        inputIngredients: [],
        lastCookedMap: {},
        recentCarbTags: ['pasta'],
      );
      expect(results.first.carbVarietyScore, 1.0);
    });

    test('carbVarietyScore = 0.0 wenn vollständige Überlappung', () {
      final recipe = _recipe(id: 'r1', name: 'Test', carbTags: ['reis']);
      final results = RecipeSuggestionService.suggest(
        recipes: [recipe],
        inputIngredients: [],
        lastCookedMap: {},
        recentCarbTags: ['reis'],
      );
      expect(results.first.carbVarietyScore, 0.0);
    });

    test('sortierung: perfect vor partial vor other', () {
      final perfect = _recipe(
        id: 'r1',
        name: 'Perfect',
        sections: [_section(['Nudeln', 'Tomaten'])],
      );
      final partial = _recipe(
        id: 'r2',
        name: 'Partial',
        sections: [_section(['Nudeln', 'Käse'])],
      );
      final other = _recipe(
        id: 'r3',
        name: 'Other',
        sections: [_section(['Reis'])],
      );

      final results = RecipeSuggestionService.suggest(
        recipes: [other, partial, perfect],
        inputIngredients: ['Nudeln', 'Tomaten'],
        lastCookedMap: {},
        recentCarbTags: [],
      );

      expect(results[0].matchQuality, MatchQuality.perfect);
      expect(results[1].matchQuality, MatchQuality.partial);
      expect(results[2].matchQuality, MatchQuality.other);
    });

    test('totalScore ist gewichtete Summe der Einzelscores', () {
      final recipe = _recipe(id: 'r1', name: 'Test', carbTags: ['reis']);
      final results = RecipeSuggestionService.suggest(
        recipes: [recipe],
        inputIngredients: ['Nudeln'],
        lastCookedMap: {'r1': 7},
        recentCarbTags: ['pasta'],
      );
      final s = results.first;
      final expected = s.ingredientScore * 0.50 +
          s.rotationScore * 0.30 +
          s.carbVarietyScore * 0.20;
      expect(s.totalScore, closeTo(expected, 0.001));
    });
  });
}
