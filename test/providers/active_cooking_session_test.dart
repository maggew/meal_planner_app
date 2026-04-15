import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/cooking_recipe_entry.dart';
import 'package:meal_planner/services/providers/cooking/active_cooking_session_provider.dart';

CookingRecipeEntry _entry({
  String recipeId = 'r1',
  String name = 'Pasta',
}) =>
    CookingRecipeEntry(recipeId: recipeId, recipeName: name);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  ActiveCookingSession notifier() =>
      container.read(activeCookingSessionProvider.notifier);

  ActiveCookingSessionState state() =>
      container.read(activeCookingSessionProvider);

  group('ActiveCookingSession', () {
    test('starts empty and inactive', () {
      final s = state();
      expect(s.recipes, isEmpty);
      expect(s.currentRecipeId, isNull);
      expect(s.isActive, isFalse);
    });

    test('addRecipe adds entry and becomes active', () {
      notifier().addRecipe(_entry());
      final s = state();
      expect(s.recipes, hasLength(1));
      expect(s.recipes.first.recipeId, 'r1');
      expect(s.isActive, isTrue);
    });

    test('addRecipe with duplicate recipeId is no-op', () {
      notifier().addRecipe(_entry());
      notifier().addRecipe(_entry(name: 'Different Name'));
      expect(state().recipes, hasLength(1));
      expect(state().recipes.first.recipeName, 'Pasta');
    });

    test('removeRecipe removes entry', () {
      notifier().addRecipe(_entry());
      notifier().removeRecipe('r1');
      expect(state().recipes, isEmpty);
      expect(state().isActive, isFalse);
    });

    test('removeRecipe with unknown id is no-op', () {
      notifier().addRecipe(_entry());
      notifier().removeRecipe('unknown');
      expect(state().recipes, hasLength(1));
    });

    test('setCurrentStep updates step for correct recipe', () {
      notifier().addRecipe(_entry(recipeId: 'r1'));
      notifier().addRecipe(_entry(recipeId: 'r2', name: 'Pizza'));
      notifier().setCurrentStep('r1', 3);
      final recipes = state().recipes;
      expect(recipes.firstWhere((e) => e.recipeId == 'r1').currentStep, 3);
      expect(recipes.firstWhere((e) => e.recipeId == 'r2').currentStep, 0);
    });

    test('setCurrentRecipe switches currentRecipeId', () {
      notifier().addRecipe(_entry(recipeId: 'r1'));
      notifier().addRecipe(_entry(recipeId: 'r2', name: 'Pizza'));
      notifier().setCurrentRecipe('r2');
      expect(state().currentRecipeId, 'r2');
    });

    test('isRecipeActive returns correct state', () {
      notifier().addRecipe(_entry(recipeId: 'r1'));
      expect(state().isRecipeActive('r1'), isTrue);
      expect(state().isRecipeActive('r2'), isFalse);
    });

    test('recipe order is preserved (insertion order)', () {
      notifier().addRecipe(_entry(recipeId: 'c'));
      notifier().addRecipe(_entry(recipeId: 'a', name: 'A'));
      notifier().addRecipe(_entry(recipeId: 'b', name: 'B'));
      final ids = state().recipes.map((e) => e.recipeId).toList();
      expect(ids, ['c', 'a', 'b']);
    });

    test('clearSession resets everything', () {
      notifier().addRecipe(_entry(recipeId: 'r1'));
      notifier().addRecipe(_entry(recipeId: 'r2', name: 'Pizza'));
      notifier().setCurrentRecipe('r2');
      notifier().clearSession();
      expect(state().recipes, isEmpty);
      expect(state().currentRecipeId, isNull);
      expect(state().isActive, isFalse);
    });

    test('first addRecipe sets currentRecipeId', () {
      notifier().addRecipe(_entry(recipeId: 'r1'));
      expect(state().currentRecipeId, 'r1');
    });

    test('removeRecipe updates currentRecipeId to next recipe', () {
      notifier().addRecipe(_entry(recipeId: 'r1'));
      notifier().addRecipe(_entry(recipeId: 'r2', name: 'Pizza'));
      notifier().setCurrentRecipe('r1');
      notifier().removeRecipe('r1');
      expect(state().currentRecipeId, 'r2');
    });
  });
}
