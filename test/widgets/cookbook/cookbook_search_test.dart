import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_button.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_searchbar.dart';
import 'package:meal_planner/services/providers/recipe/recipe_search_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';

// --- Test Data ---

Recipe _recipe({
  required String id,
  required String name,
  List<String> categories = const [],
  int portions = 4,
  List<IngredientSection> ingredientSections = const [],
  String instructions = '',
  String? imageUrl,
  List<String> carbTags = const [],
}) {
  return Recipe(
    id: id,
    name: name,
    categories: categories,
    portions: portions,
    ingredientSections: ingredientSections,
    instructions: instructions,
    imageUrl: imageUrl,
    carbTags: carbTags,
  );
}

final _spaghetti = _recipe(id: '1', name: 'Spaghetti Bolognese');
final _pizza = _recipe(id: '2', name: 'Pizza Margherita');
final _spaetzle = _recipe(id: '3', name: 'Käsespätzle');
final _spargel = _recipe(id: '4', name: 'Spargel Risotto');

// --- Fakes ---

class FakeUserSettingsNotifier extends UserSettingsNotifier {
  @override
  UserSettings build() => UserSettings.defaultSettings;
}

class FakeRecipeRepository implements RecipeRepository {
  final List<Recipe> allRecipes;
  final Map<String, List<Recipe>> recipesByCategory;

  FakeRecipeRepository(this.allRecipes, {this.recipesByCategory = const {}});

  @override
  Future<List<Recipe>> searchRecipes(String query) async {
    final q = query.toLowerCase();
    return allRecipes
        .where((r) => r.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<Recipe>> getRecipesByCategoryId({
    required String categoryId,
    required RecipeSortOption sortOption,
    required bool isDeleted,
  }) async {
    return recipesByCategory[categoryId] ?? [];
  }

  @override
  Future<String> saveRecipe(Recipe recipe, File? image, String createdBy) =>
      throw UnimplementedError();
  @override
  Future<List<Recipe>> getRecipesByCategories(List<String> categories) =>
      throw UnimplementedError();
  @override
  Future<Recipe?> getRecipeById(String recipeId) => throw UnimplementedError();
  @override
  Future<void> updateRecipe(Recipe recipe, File? newImage) =>
      throw UnimplementedError();
  @override
  Future<void> deleteRecipe(String recipeId) => throw UnimplementedError();
  @override
  Future<List<String>> getAllCategories() => throw UnimplementedError();
  @override
  Future<String?> getRecipeTitle(String recipeId) => throw UnimplementedError();
  @override
  Future<List<RecipeTimer>> getTimersForRecipe(String recipeId) =>
      throw UnimplementedError();
  @override
  Future<RecipeTimer> upsertTimer(RecipeTimer timer) =>
      throw UnimplementedError();
  @override
  Future<void> deleteTimer(String recipeId, int stepIndex) =>
      throw UnimplementedError();
  @override
  Future<void> incrementTimesCooked(String recipeId) =>
      throw UnimplementedError();
}

// --- Helpers ---

ProviderContainer _createContainer({
  List<Recipe> allRecipesForSearch = const [],
  Map<String, List<Recipe>> recipesByCategory = const {},
}) {
  return ProviderContainer(overrides: [
    userSettingsProvider.overrideWith(() => FakeUserSettingsNotifier()),
    if (allRecipesForSearch.isNotEmpty || recipesByCategory.isNotEmpty)
      recipeRepositoryProvider.overrideWithValue(
        FakeRecipeRepository(allRecipesForSearch,
            recipesByCategory: recipesByCategory),
      ),
  ]);
}

Widget _buildSearchbar() {
  return ProviderScope(
    overrides: [
      userSettingsProvider.overrideWith(() => FakeUserSettingsNotifier()),
    ],
    child: MaterialApp(
      home: Scaffold(body: CookbookSearchbar()),
    ),
  );
}

// =============================================================================

void main() {
  // ===== Provider Unit Tests =====

  group('SearchQuery provider', () {
    test('initial value is empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(searchQueryProvider), '');
    });

    test('set updates the query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).set('pasta');
      expect(container.read(searchQueryProvider), 'pasta');
    });

    test('clear resets to empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).set('pasta');
      container.read(searchQueryProvider.notifier).clear();
      expect(container.read(searchQueryProvider), '');
    });
  });

  group('IsSearchActive provider', () {
    test('inactive when query is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(isSearchActiveProvider), false);
    });

    test('inactive when query has fewer than 3 characters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).set('ab');
      expect(container.read(isSearchActiveProvider), false);
    });

    test('active when query has 3 or more characters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).set('abc');
      expect(container.read(isSearchActiveProvider), true);
    });

    test('inactive when query is only whitespace', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).set('     ');
      expect(container.read(isSearchActiveProvider), false);
    });

    test('trims whitespace before checking length', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).set('  ab  ');
      expect(container.read(isSearchActiveProvider), false);

      container.read(searchQueryProvider.notifier).set('  abc  ');
      expect(container.read(isSearchActiveProvider), true);
    });
  });

  group('categoryRecipesProvider', () {
    test('returns recipes for a category from the repository', () async {
      final container = _createContainer(
        recipesByCategory: {
          'cat-1': [_spaghetti, _pizza],
          'cat-2': [_spaetzle, _spargel],
        },
      );
      addTearDown(container.dispose);

      final result =
          await container.read(categoryRecipesProvider('cat-1').future);

      expect(result, [_spaghetti, _pizza]);
    });

    test('returns empty list for unknown category', () async {
      final container = _createContainer(
        recipesByCategory: {
          'cat-1': [_spaghetti],
        },
      );
      addTearDown(container.dispose);

      final result =
          await container.read(categoryRecipesProvider('cat-99').future);

      expect(result, isEmpty);
    });
  });

  group('searchResultsProvider', () {
    test('returns empty list when query has fewer than 3 chars', () async {
      final container = _createContainer(
        allRecipesForSearch: [_spaghetti, _pizza, _spaetzle],
      );
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).set('Sp');

      final result = await container.read(searchResultsProvider.future);
      expect(result, isEmpty);
    });

    test('searches recipes from repository with 3+ chars', () async {
      final container = _createContainer(
        allRecipesForSearch: [_spaghetti, _pizza, _spaetzle, _spargel],
      );
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).set('Spa');

      final result = await container.read(searchResultsProvider.future);
      expect(result.length, 2); // Spaghetti, Spargel (Käsespätzle has 'spä' not 'spa')
    });

    test('finds recipes across all categories', () async {
      final container = _createContainer(
        allRecipesForSearch: [_spaghetti, _pizza, _spaetzle, _spargel],
      );
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).set('Spä');

      final result = await container.read(searchResultsProvider.future);
      expect(result.any((r) => r.name == 'Käsespätzle'), isTrue);
    });

    test('returns empty list when no recipes match', () async {
      final container = _createContainer(
        allRecipesForSearch: [_spaghetti, _pizza],
      );
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).set('xyz');

      final result = await container.read(searchResultsProvider.future);
      expect(result, isEmpty);
    });
  });

  // ===== Change Detection Tests =====

  group('hasRecipeChanged', () {
    test('returns false for identical recipes without new image', () {
      final recipe = _recipe(
        id: '1',
        name: 'Test',
        categories: ['cat-a'],
        portions: 4,
        instructions: 'Do stuff',
        carbTags: ['reis'],
        ingredientSections: [
          IngredientSection(title: 'Zutaten', ingredients: [
            Ingredient(name: 'Tomate', amount: '2', unit: null),
          ]),
        ],
      );

      expect(hasRecipeChanged(recipe, recipe, null), false);
    });

    test('returns true when new image is provided', () {
      final recipe = _recipe(id: '1', name: 'Test');
      final file = File('test.png');

      expect(hasRecipeChanged(recipe, recipe, file), true);
    });

    test('returns true when name changes', () {
      final old = _recipe(id: '1', name: 'Old Name');
      final updated = _recipe(id: '1', name: 'New Name');

      expect(hasRecipeChanged(old, updated, null), true);
    });

    test('returns true when instructions change', () {
      final old = _recipe(id: '1', name: 'Test', instructions: 'Step 1');
      final updated = _recipe(id: '1', name: 'Test', instructions: 'Step 2');

      expect(hasRecipeChanged(old, updated, null), true);
    });

    test('returns true when portions change', () {
      final old = _recipe(id: '1', name: 'Test', portions: 4);
      final updated = _recipe(id: '1', name: 'Test', portions: 2);

      expect(hasRecipeChanged(old, updated, null), true);
    });

    test('returns true when categories change', () {
      final old = _recipe(id: '1', name: 'Test', categories: ['a', 'b']);
      final updated = _recipe(id: '1', name: 'Test', categories: ['a', 'c']);

      expect(hasRecipeChanged(old, updated, null), true);
    });

    test('returns false when categories are in different order', () {
      final old = _recipe(id: '1', name: 'Test', categories: ['b', 'a']);
      final updated = _recipe(id: '1', name: 'Test', categories: ['a', 'b']);

      expect(hasRecipeChanged(old, updated, null), false);
    });

    test('returns true when carbTags change', () {
      final old = _recipe(id: '1', name: 'Test', carbTags: ['reis']);
      final updated = _recipe(id: '1', name: 'Test', carbTags: ['pasta']);

      expect(hasRecipeChanged(old, updated, null), true);
    });

    test('returns true when ingredients change', () {
      final old = _recipe(
        id: '1',
        name: 'Test',
        ingredientSections: [
          IngredientSection(title: 'Zutaten', ingredients: [
            Ingredient(name: 'Tomate', amount: '2', unit: null),
          ]),
        ],
      );
      final updated = _recipe(
        id: '1',
        name: 'Test',
        ingredientSections: [
          IngredientSection(title: 'Zutaten', ingredients: [
            Ingredient(name: 'Gurke', amount: '1', unit: null),
          ]),
        ],
      );

      expect(hasRecipeChanged(old, updated, null), true);
    });

    test('returns true when ingredient section is added', () {
      final old = _recipe(
        id: '1',
        name: 'Test',
        ingredientSections: [
          IngredientSection(title: 'A', ingredients: []),
        ],
      );
      final updated = _recipe(
        id: '1',
        name: 'Test',
        ingredientSections: [
          IngredientSection(title: 'A', ingredients: []),
          IngredientSection(title: 'B', ingredients: []),
        ],
      );

      expect(hasRecipeChanged(old, updated, null), true);
    });
  });

  // ===== Widget Tests =====

  group('CookbookSearchbar widget', () {
    testWidgets('renders search field with "Suche" hint', (tester) async {
      await tester.pumpWidget(_buildSearchbar());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Suche'), findsOneWidget);
    });

    testWidgets('does not show searchAll filter chip', (tester) async {
      await tester.pumpWidget(_buildSearchbar());
      await tester.pumpAndSettle();

      expect(find.text('Alle'), findsNothing,
          reason: 'searchAll toggle should be removed — '
              'search always covers all categories');
    });

    testWidgets('shows clear button when text is entered', (tester) async {
      await tester.pumpWidget(_buildSearchbar());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.clear), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'ab');
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clear button removes text and resets provider', (tester) async {
      await tester.pumpWidget(_buildSearchbar());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'pasta');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.controller.text, '');
    });

    testWidgets('shows hint when 1-2 chars entered', (tester) async {
      await tester.pumpWidget(_buildSearchbar());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'ab');
      await tester.pumpAndSettle();

      expect(find.text('Mindestens 3 Zeichen eingeben'), findsOneWidget);
    });

    testWidgets('hides hint when query is empty', (tester) async {
      await tester.pumpWidget(_buildSearchbar());
      await tester.pumpAndSettle();

      expect(find.text('Mindestens 3 Zeichen eingeben'), findsNothing);
    });

    testWidgets('hides hint when query has 3+ chars', (tester) async {
      await tester.pumpWidget(_buildSearchbar());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pumpAndSettle();

      expect(find.text('Mindestens 3 Zeichen eingeben'), findsNothing);
    });
  });
}
