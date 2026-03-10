import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/recipe_suggestion.dart';
import 'package:meal_planner/domain/services/recipe_suggestion_service.dart';

void main() {
  Recipe recipe({
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

  IngredientSection section(List<String> names) => IngredientSection(
        title: 'Zutaten',
        ingredients:
            names.map((n) => Ingredient(name: n, unit: null, amount: null)).toList(),
      );

  // ==================== MatchQuality ====================

  group('RecipeSuggestionService — MatchQuality', () {
    test('perfect wenn alle Input-Zutaten matchen', () {
      final r = recipe(id: 'r1', name: 'Pasta', sections: [section(['Nudeln', 'Tomaten'])]);
      final results = RecipeSuggestionService.suggest(
        recipes: [r],
        inputIngredients: ['Nudeln', 'Tomaten'],
        lastCookedMap: {},
        recentCarbTags: [],
      );
      expect(results.first.matchQuality, MatchQuality.perfect);
      expect(results.first.matchedIngredientCount, 2);
    });

    test('partial wenn nur ein Teil matcht', () {
      final r = recipe(id: 'r1', name: 'Pasta', sections: [section(['Nudeln', 'Tomaten', 'Käse'])]);
      final results = RecipeSuggestionService.suggest(
        recipes: [r],
        inputIngredients: ['Nudeln', 'Zwiebeln'],
        lastCookedMap: {},
        recentCarbTags: [],
      );
      expect(results.first.matchQuality, MatchQuality.partial);
      expect(results.first.matchedIngredientCount, 1);
    });

    test('other wenn keine Zutat matcht', () {
      final r = recipe(id: 'r1', name: 'Pasta', sections: [section(['Nudeln', 'Tomaten'])]);
      final results = RecipeSuggestionService.suggest(
        recipes: [r],
        inputIngredients: ['Reis', 'Kartoffeln'],
        lastCookedMap: {},
        recentCarbTags: [],
      );
      expect(results.first.matchQuality, MatchQuality.other);
    });

    test('other + ingredientScore 0.5 bei leerer Eingabe', () {
      final r = recipe(id: 'r1', name: 'Test');
      final results = RecipeSuggestionService.suggest(
        recipes: [r],
        inputIngredients: [],
        lastCookedMap: {},
        recentCarbTags: [],
      );
      expect(results.first.matchQuality, MatchQuality.other);
      expect(results.first.ingredientScore, 0.5);
    });
  });

  // ==================== Ingredient Scoring ====================

  group('RecipeSuggestionService — Ingredient Scoring', () {
    test('fuzzyMatch: Plural-Input trifft Singular-Rezept', () {
      final r = recipe(id: 'r1', name: 'Test', sections: [section(['Tomate'])]);
      final results = RecipeSuggestionService.suggest(
        recipes: [r],
        inputIngredients: ['Tomaten'],
        lastCookedMap: {},
        recentCarbTags: [],
      );
      expect(results.first.matchedIngredientCount, 1);
    });

    test('Rezept ohne id wird ausgeschlossen', () {
      final withId = recipe(id: 'r1', name: 'Mit ID');
      final withoutId = Recipe(
        id: null,
        name: 'Ohne ID',
        categories: [],
        portions: 2,
        ingredientSections: [],
        instructions: '',
        carbTags: [],
      );
      final results = RecipeSuggestionService.suggest(
        recipes: [withId, withoutId],
        inputIngredients: [],
        lastCookedMap: {},
        recentCarbTags: [],
      );
      expect(results.length, 1);
      expect(results.first.recipe.id, 'r1');
    });

    test('leere Rezeptliste → leeres Ergebnis', () {
      final results = RecipeSuggestionService.suggest(
        recipes: [],
        inputIngredients: ['Nudeln'],
        lastCookedMap: {},
        recentCarbTags: [],
      );
      expect(results, isEmpty);
    });
  });

  // ==================== Rotation Scoring ====================

  group('RecipeSuggestionService — Rotation Scoring', () {
    test('nie gekocht (null) → rotationScore 1.0', () {
      final r = recipe(id: 'r1', name: 'Test');
      final results = RecipeSuggestionService.suggest(
        recipes: [r], inputIngredients: [], lastCookedMap: {}, recentCarbTags: [],
      );
      expect(results.first.rotationScore, 1.0);
    });

    test('heute gekocht (0 Tage) → rotationScore 0.0', () {
      final r = recipe(id: 'r1', name: 'Test');
      final results = RecipeSuggestionService.suggest(
        recipes: [r], inputIngredients: [], lastCookedMap: {'r1': 0}, recentCarbTags: [],
      );
      expect(results.first.rotationScore, 0.0);
    });

    test('vor 7 Tagen → rotationScore 0.5', () {
      final r = recipe(id: 'r1', name: 'Test');
      final results = RecipeSuggestionService.suggest(
        recipes: [r], inputIngredients: [], lastCookedMap: {'r1': 7}, recentCarbTags: [],
      );
      expect(results.first.rotationScore, closeTo(0.5, 0.001));
    });

    test('vor 14 Tagen → rotationScore 1.0', () {
      final r = recipe(id: 'r1', name: 'Test');
      final results = RecipeSuggestionService.suggest(
        recipes: [r], inputIngredients: [], lastCookedMap: {'r1': 14}, recentCarbTags: [],
      );
      expect(results.first.rotationScore, 1.0);
    });

    test('vor 28 Tagen → rotationScore 1.0 (Clamp, nicht 2.0)', () {
      final r = recipe(id: 'r1', name: 'Test');
      final results = RecipeSuggestionService.suggest(
        recipes: [r], inputIngredients: [], lastCookedMap: {'r1': 28}, recentCarbTags: [],
      );
      expect(results.first.rotationScore, 1.0);
    });
  });

  // ==================== Carb Variety Scoring ====================

  group('RecipeSuggestionService — Carb Variety Scoring', () {
    test('keine recentCarbTags → carbVarietyScore 1.0', () {
      final r = recipe(id: 'r1', name: 'Test', carbTags: ['reis']);
      final results = RecipeSuggestionService.suggest(
        recipes: [r], inputIngredients: [], lastCookedMap: {}, recentCarbTags: [],
      );
      expect(results.first.carbVarietyScore, 1.0);
    });

    test('Rezept ohne carbTags → carbVarietyScore 1.0', () {
      final r = recipe(id: 'r1', name: 'Test', carbTags: []);
      final results = RecipeSuggestionService.suggest(
        recipes: [r], inputIngredients: [], lastCookedMap: {}, recentCarbTags: ['reis'],
      );
      expect(results.first.carbVarietyScore, 1.0);
    });

    test('kein Overlap → carbVarietyScore 1.0', () {
      final r = recipe(id: 'r1', name: 'Test', carbTags: ['reis']);
      final results = RecipeSuggestionService.suggest(
        recipes: [r], inputIngredients: [], lastCookedMap: {}, recentCarbTags: ['pasta'],
      );
      expect(results.first.carbVarietyScore, 1.0);
    });

    test('vollständiger Overlap (1/1) → carbVarietyScore 0.0', () {
      final r = recipe(id: 'r1', name: 'Test', carbTags: ['reis']);
      final results = RecipeSuggestionService.suggest(
        recipes: [r], inputIngredients: [], lastCookedMap: {}, recentCarbTags: ['reis'],
      );
      expect(results.first.carbVarietyScore, 0.0);
    });

    test('halber Overlap (1/2) → carbVarietyScore 0.5', () {
      final r = recipe(id: 'r1', name: 'Test', carbTags: ['reis', 'pasta']);
      final results = RecipeSuggestionService.suggest(
        recipes: [r], inputIngredients: [], lastCookedMap: {}, recentCarbTags: ['reis'],
      );
      expect(results.first.carbVarietyScore, closeTo(0.5, 0.001));
    });
  });

  // ==================== Gewichte & useCarbVariety ====================

  group('RecipeSuggestionService — Gewichte', () {
    test('totalScore = gewichtete Summe (50/30/20)', () {
      final r = recipe(id: 'r1', name: 'Test', carbTags: ['reis']);
      final results = RecipeSuggestionService.suggest(
        recipes: [r],
        inputIngredients: ['Nudeln'],
        lastCookedMap: {'r1': 7},
        recentCarbTags: ['pasta'],
      );
      final s = results.first;
      final expected =
          s.ingredientScore * 0.50 + s.rotationScore * 0.30 + s.carbVarietyScore * 0.20;
      expect(s.totalScore, closeTo(expected, 0.001));
    });

    test('carbVarietyWeight=0 → Gewichte 4/8 + 4/8, carbVariety ignoriert', () {
      final r = recipe(id: 'r1', name: 'Test', carbTags: ['reis']);
      final results = RecipeSuggestionService.suggest(
        recipes: [r],
        inputIngredients: [],
        lastCookedMap: {'r1': 7},
        recentCarbTags: ['reis'],
        carbVarietyWeight: 0,
      );
      final s = results.first;
      // carbVarietyWeight=0: ingredient bekommt 0.5, rotation bekommt alle restlichen 0.5
      final expected = s.ingredientScore * 0.5 + s.rotationScore * 0.5;
      expect(s.totalScore, closeTo(expected, 0.001));
    });

    test('carbVarietyWeight=0 → carbVarietyScore hat keinen Einfluss auf totalScore', () {
      final withOverlap = recipe(id: 'r1', name: 'Mit Overlap', carbTags: ['reis']);
      final withoutOverlap = recipe(id: 'r2', name: 'Kein Overlap', carbTags: ['pasta']);

      List<RecipeSuggestion> suggest(Recipe r) => RecipeSuggestionService.suggest(
            recipes: [r],
            inputIngredients: [],
            lastCookedMap: {},
            recentCarbTags: ['reis'],
            carbVarietyWeight: 0,
          );

      expect(
        suggest(withOverlap).first.totalScore,
        closeTo(suggest(withoutOverlap).first.totalScore, 0.001),
      );
    });
  });

  // ==================== Sortierung ====================

  group('RecipeSuggestionService — Sortierung', () {
    test('perfect vor partial vor other', () {
      final perfect = recipe(id: 'r1', name: 'Perfect', sections: [section(['Nudeln', 'Tomaten'])]);
      final partial = recipe(id: 'r2', name: 'Partial', sections: [section(['Nudeln', 'Käse'])]);
      final other = recipe(id: 'r3', name: 'Other', sections: [section(['Reis'])]);

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

    test('gleiche Quality → höherer totalScore zuerst', () {
      final besser = recipe(id: 'r1', name: 'Besser', sections: [section(['Nudeln'])]);
      final schlechter = recipe(id: 'r2', name: 'Schlechter', sections: [section(['Nudeln'])]);

      // r1 wurde nie gekocht (rotationScore 1.0), r2 gestern (rotationScore ~0.07)
      final results = RecipeSuggestionService.suggest(
        recipes: [schlechter, besser],
        inputIngredients: ['Nudeln'],
        lastCookedMap: {'r2': 1},
        recentCarbTags: [],
      );

      expect(results.first.recipe.id, 'r1');
    });
  });
}
