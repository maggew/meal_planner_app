import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/converters/recipe_cache_converter.dart';
import 'package:meal_planner/data/model/recipe_model.dart';
import 'package:meal_planner/domain/entities/recipe.dart';

Recipe _makeRecipe({int? timesCooked}) => Recipe(
      id: 'r1',
      name: 'Pasta',
      categories: ['Italienisch'],
      portions: 2,
      ingredientSections: [],
      instructions: '1. Kochen',
      timesCooked: timesCooked ?? 0,
    );

void main() {
  group('Recipe entity — timesCooked', () {
    test('defaults to 0 when not provided', () {
      final recipe = Recipe(
        id: 'r1',
        name: 'Pasta',
        categories: [],
        portions: 2,
        ingredientSections: [],
        instructions: '',
      );
      expect(recipe.timesCooked, 0);
    });

    test('stores provided value', () {
      final recipe = _makeRecipe(timesCooked: 5);
      expect(recipe.timesCooked, 5);
    });

    test('copyWith preserves timesCooked when not overridden', () {
      final recipe = _makeRecipe(timesCooked: 3);
      final copy = recipe.copyWith(name: 'Pizza');
      expect(copy.timesCooked, 3);
      expect(copy.name, 'Pizza');
    });

    test('copyWith overrides timesCooked', () {
      final recipe = _makeRecipe(timesCooked: 3);
      final copy = recipe.copyWith(timesCooked: 10);
      expect(copy.timesCooked, 10);
    });
  });

  group('RecipeModel — timesCooked', () {
    test('fromSupabaseWithRelations parses times_cooked', () {
      final data = {
        'id': 'r1',
        'title': 'Pasta',
        'instructions': '1. Kochen',
        'image_url': null,
        'portions': 2,
        'times_cooked': 7,
        'carb_tags': <dynamic>[],
        'recipe_categories': <dynamic>[],
        'recipe_ingredients': <dynamic>[],
      };
      final model = RecipeModel.fromSupabaseWithRelations(data);
      expect(model.timesCooked, 7);
    });

    test('fromSupabaseWithRelations defaults to 0 when missing', () {
      final data = {
        'id': 'r1',
        'title': 'Pasta',
        'instructions': '1. Kochen',
        'image_url': null,
        'portions': 2,
        'carb_tags': <dynamic>[],
        'recipe_categories': <dynamic>[],
        'recipe_ingredients': <dynamic>[],
      };
      final model = RecipeModel.fromSupabaseWithRelations(data);
      expect(model.timesCooked, 0);
    });

    test('fromEntity and toEntity round-trip preserves timesCooked', () {
      final recipe = _makeRecipe(timesCooked: 12);
      final model = RecipeModel.fromEntity(recipe);
      expect(model.timesCooked, 12);

      final entity = model.toEntity();
      expect(entity.timesCooked, 12);
    });
  });

  group('RecipeCacheConverter — timesCooked', () {
    test('toCompanion writes timesCooked', () {
      final recipe = _makeRecipe(timesCooked: 5);
      final companion = RecipeCacheConverter.toCompanion(
        recipe,
        groupId: 'g1',
        timers: [],
      );
      expect(companion.timesCooked, const Value(5));
    });

    test('toRecipe reads timesCooked from LocalRecipe row', () {
      final now = DateTime.now();
      final row = LocalRecipe(
        id: 'r1',
        groupId: 'g1',
        name: 'Pasta',
        portions: 2,
        instructions: '1. Kochen',
        imageUrl: null,
        createdAt: now,
        categoriesJson: '["Italienisch"]',
        ingredientSectionsJson: '[]',
        timersJson: '[]',
        carbTagsJson: '[]',
        timesCooked: 8,
        updatedAt: null,
        isDeleted: false,
        cachedAt: now,
      );
      final recipe = RecipeCacheConverter.toRecipe(row);
      expect(recipe.timesCooked, 8);
    });
  });
}
