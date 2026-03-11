import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/model/recipe_model.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/exceptions/recipe_exceptions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meal_planner/data/repositories/supabase_recipe_repository.dart';
import 'package:meal_planner/data/datasources/recipe_remote_datasource.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockRecipeRemoteDataSource extends Mock
    implements RecipeRemoteDatasource {}

class MockStorageRepository extends Mock implements StorageRepository {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockRecipeRemoteDataSource remote;
  late MockStorageRepository storage;
  late SupabaseRecipeRepository repository;
  late MockSupabaseClient supabase;

  setUp(() {
    remote = MockRecipeRemoteDataSource();
    storage = MockStorageRepository();
    supabase = MockSupabaseClient();

    repository = SupabaseRecipeRepository(
      supabase: supabase, // wird hier nicht benutzt
      storage: storage,
      remote: remote,
      groupId: 'group-1',
    );

    registerFallbackValue(File("dummyFile"));
    registerFallbackValue(RecipeModel(
        name: "",
        categories: [],
        portions: 4,
        ingredientSections: [],
        instructions: ""));
    registerFallbackValue(<String, dynamic>{});
  });

  // Helper: minimal timer map matching RecipeTimerModel.fromSupabase
  Map<String, dynamic> _timerMap() => {
        'id': 'timer-1',
        'recipe_id': 'r1',
        'step_index': 0,
        'timer_name': 'Kochen',
        'duration_seconds': 300,
      };

  RecipeTimer _fakeTimer() => RecipeTimer(
        id: 'timer-1',
        recipeId: 'r1',
        stepIndex: 0,
        timerName: 'Kochen',
        durationSeconds: 300,
      );

  group("getRecipeById", () {
    test('getRecipeById returns Recipe when datasource returns data', () async {
      // arrange
      final fakeSupabaseResponse = {
        'id': 'recipe-1',
        'title': 'Pasta',
        'description': 'Simple pasta',
        'image_url': null,
        'created_at': DateTime.now().toIso8601String(),
        'recipe_categories': [],
        'recipe_ingredients': [],
      };

      when(() => remote.getRecipeById(
            recipeId: 'recipe-1',
            groupId: 'group-1',
          )).thenAnswer((_) async => fakeSupabaseResponse);

      // act
      final result = await repository.getRecipeById('recipe-1');

      // assert
      expect(result, isA<Recipe>());
      expect(result!.name, 'Pasta');
    });

    test('getRecipeById returns null when datasource returns null', () async {
      // arrange
      when(() => remote.getRecipeById(
            recipeId: 'recipe-1',
            groupId: 'group-1',
          )).thenAnswer((_) async => null);

      // act
      final result = await repository.getRecipeById('recipe-1');

      // assert
      expect(result, isNull);
    });

    test('getRecipeById throws RecipeNotFoundException on datasource error',
        () async {
      // arrange
      when(() => remote.getRecipeById(
            recipeId: 'recipe-1',
            groupId: 'group-1',
          )).thenThrow(Exception('boom'));

      // act & assert
      expect(
        repository.getRecipeById('recipe-1'),
        throwsA(isA<RecipeNotFoundException>()),
      );
    });
  });

  group("getAllCategories", () {
    test("return categories from datasource", () async {
      // arrange
      List<String> expectedList = ['dessert', 'pasta'];
      when(() => remote.getAllCategories(groupId: any(named: 'groupId')))
          .thenAnswer((_) async => expectedList);

      // act
      final result = await repository.getAllCategories();

      // assert
      expect(result, expectedList);
    });

    test("returns empty list when datasource throws", () async {
      //arrange
      when(() => remote.getAllCategories(groupId: any(named: 'groupId'))).thenThrow(Exception("boom"));

      // act
      final result = await repository.getAllCategories();

      // assert
      expect(result, isEmpty);
    });
  });

  group('getRecipesByCategoryId', () {
    test('returns mapped recipes when datasource returns data', () async {
      // arrange
      final fakeResponse = [
        {
          'id': 'r1',
          'title': 'Pasta',
          'description': 'Simple pasta',
          'image_url': null,
          'created_at': DateTime.now().toIso8601String(),
          'recipe_categories': [],
          'recipe_ingredients': [],
        },
        {
          'id': 'r2',
          'title': 'Salad',
          'description': 'Fresh salad',
          'image_url': null,
          'created_at': DateTime.now().toIso8601String(),
          'recipe_categories': [],
          'recipe_ingredients': [],
        },
      ];

      when(() => remote.getRecipesByCategoryId(
            categoryId: 'cat-1',
            groupId: 'group-1',
            isDeleted: false,
            limit: 20,
            offset: 0,
            sortOption: RecipeSortOption.alphabetical,
          )).thenAnswer((_) async => fakeResponse);

      // act
      final result = await repository.getRecipesByCategoryId(
        categoryId: 'cat-1',
        limit: 20,
        offset: 0,
        sortOption: RecipeSortOption.alphabetical,
        isDeleted: false,
      );

      // assert
      expect(result.length, 2);
      expect(result.first.name, 'Pasta');
      expect(result.last.name, 'Salad');
    });

    test('returns empty list when datasource returns empty list', () async {
      // arrange
      when(() => remote.getRecipesByCategoryId(
            categoryId: 'cat-1',
            groupId: 'group-1',
            isDeleted: false,
            limit: 20,
            offset: 0,
            sortOption: RecipeSortOption.alphabetical,
          )).thenAnswer((_) async => []);

      // act
      final result = await repository.getRecipesByCategoryId(
        categoryId: 'cat-1',
        limit: 20,
        offset: 0,
        sortOption: RecipeSortOption.alphabetical,
        isDeleted: false,
      );

      // assert
      expect(result, isEmpty);
    });

    test('throws RecipeNotFoundException when datasource throws', () async {
      // arrange
      when(() => remote.getRecipesByCategoryId(
            categoryId: 'cat-1',
            groupId: 'group-1',
            isDeleted: false,
            limit: 20,
            offset: 0,
            sortOption: RecipeSortOption.alphabetical,
          )).thenThrow(Exception('boom'));

      // act & assert
      expect(
        repository.getRecipesByCategoryId(
          categoryId: 'cat-1',
          limit: 20,
          offset: 0,
          sortOption: RecipeSortOption.alphabetical,
          isDeleted: false,
        ),
        throwsA(isA<RecipeNotFoundException>()),
      );
    });
  });

  group('getRecipesByCategories', () {
    test('returns mapped recipes when datasource returns data', () async {
      // arrange
      final fakeResponse = [
        {
          'id': 'r1',
          'title': 'Pasta',
          'description': 'Simple pasta',
          'image_url': null,
          'created_at': DateTime.now().toIso8601String(),
          'recipe_categories': [],
          'recipe_ingredients': [],
        },
        {
          'id': 'r2',
          'title': 'Salad',
          'description': 'Fresh salad',
          'image_url': null,
          'created_at': DateTime.now().toIso8601String(),
          'recipe_categories': [],
          'recipe_ingredients': [],
        },
      ];

      when(() => remote.getRecipesByCategories(
            categories: ['pasta', 'salad'],
            groupId: 'group-1',
          )).thenAnswer((_) async => fakeResponse);

      // act
      final result =
          await repository.getRecipesByCategories(['pasta', 'salad']);

      // assert
      expect(result.length, 2);
      expect(result.first.name, 'Pasta');
      expect(result.last.name, 'Salad');
    });

    test('returns empty list when datasource returns empty list', () async {
      // arrange
      when(() => remote.getRecipesByCategories(
            categories: ['pasta', 'salad'],
            groupId: 'group-1',
          )).thenAnswer((_) async => []);

      // act
      final result =
          await repository.getRecipesByCategories(['pasta', 'salad']);

      // assert
      expect(result, isEmpty);
    });

    test('throws RecipeNotFoundException when datasource throws', () async {
      // arrange
      when(() => remote.getRecipesByCategories(
            categories: ['pasta', 'salad'],
            groupId: 'group-1',
          )).thenThrow(Exception('boom'));

      // act & assert
      expect(
        repository.getRecipesByCategories(['pasta', 'salad']),
        throwsA(isA<RecipeNotFoundException>()),
      );
    });
  });

  group('deleteRecipe (soft delete)', () {
    test('calls softDeleteRecipe on datasource', () async {
      // arrange
      when(() => remote.softDeleteRecipe('r1')).thenAnswer((_) async {});

      // act
      await repository.deleteRecipe('r1');

      // assert
      verify(() => remote.softDeleteRecipe('r1')).called(1);
    });

    test('throws RecipeDeletionException on error', () async {
      // arrange
      when(() => remote.softDeleteRecipe('r1')).thenThrow(Exception('boom'));

      // act & assert
      expect(
        repository.deleteRecipe('r1'),
        throwsA(isA<RecipeDeletionException>()),
      );
    });
  });

  group('updateRecipe', () {
    test('throws RecipeUpdateException when recipe has no id', () async {
      final recipe = Recipe(
        id: null,
        name: 'Pasta',
        ingredientSections: [],
        categories: [],
        portions: 2,
        instructions: '',
      );

      expect(
        repository.updateRecipe(recipe, null),
        throwsA(isA<RecipeUpdateException>()),
      );
    });

    test('updates recipe without new image', () async {
      // arrange
      final recipe = Recipe(
        id: "r1",
        name: 'Pasta',
        ingredientSections: [],
        categories: [],
        portions: 2,
        instructions: '',
      );
      when(() => remote.updateRecipe(any(), any())).thenAnswer((_) async {});
      when(() => remote.saveRecipeCategories(
            recipeId: 'r1',
            categories: any(named: 'categories'),
            groupId: any(named: 'groupId'),
          )).thenAnswer((_) async {});

      when(() => remote.saveRecipeIngredients(
            recipeId: 'r1',
            ingredients: any(named: 'ingredients'),
          )).thenAnswer((_) async {});
      when(() => storage.deleteImage(any())).thenAnswer((_) async {});

      when(() => storage.uploadImage(any<File>(), any()))
          .thenAnswer((_) async => 'imageUrl');
      when(() => remote.deleteRecipeCategories(any())).thenAnswer((_) async {});
      when(() => remote.deleteRecipeIngredients(any()))
          .thenAnswer((_) async {});
      // act
      await repository.updateRecipe(recipe, null);

      // assert
      verifyNever(() => storage.deleteImage(any()));
      verifyNever(() => storage.uploadImage(any<File>(), any()));

      verify(() => remote.updateRecipe("r1", any())).called(1);
      verify(() => remote.saveRecipeCategories(
            recipeId: 'r1',
            categories: any(named: 'categories'),
            groupId: any(named: 'groupId'),
          )).called(1);

      verify(() => remote.saveRecipeIngredients(
            recipeId: 'r1',
            ingredients: any(named: 'ingredients'),
          )).called(1);
    });

    test('updateRecipe deletes categories before inserting new ones', () async {
      // Arrange
      final recipe = Recipe(
        id: "r1",
        name: 'Pasta',
        ingredientSections: [],
        categories: [],
        portions: 2,
        instructions: '',
      );
      final callOrder = <String>[];

      when(() => remote.updateRecipe(any(), any())).thenAnswer((_) async {});
      when(() => remote.saveRecipeCategories(
            recipeId: 'r1',
            categories: any(named: 'categories'),
            groupId: any(named: 'groupId'),
          )).thenAnswer((_) async => callOrder.add('save'));

      when(() => remote.saveRecipeIngredients(
            recipeId: 'r1',
            ingredients: any(named: 'ingredients'),
          )).thenAnswer((_) async {});
      when(() => storage.deleteImage(any())).thenAnswer((_) async {});

      when(() => storage.uploadImage(any<File>(), any()))
          .thenAnswer((_) async => 'imageUrl');
      when(() => remote.deleteRecipeCategories(any()))
          .thenAnswer((_) async => callOrder.add('delete'));
      when(() => remote.deleteRecipeIngredients(any()))
          .thenAnswer((_) async {});

      // Act
      await repository.updateRecipe(recipe, null);

      // Assert
      expect(callOrder, ['delete', 'save']);
    });

    test('updates recipe and replaces old image when new image is provided',
        () async {
      // arrange
      final recipe = Recipe(
        id: "r1",
        name: 'Pasta',
        ingredientSections: [],
        categories: [],
        portions: 2,
        instructions: '',
        imageUrl: "old_image_url",
      );
      final file = File("dummy");
      when(() => remote.updateRecipe("r1", any())).thenAnswer((_) async {});
      when(() => remote.deleteRecipeCategories('r1')).thenAnswer((_) async {});
      when(() => remote.deleteRecipeIngredients('r1')).thenAnswer((_) async {});
      when(() => storage.deleteImage("old_image_url")).thenAnswer((_) async {});
      when(() => storage.uploadImage(any<File>(), any()))
          .thenAnswer((_) async => "imageUrl");
      when(() => remote.saveRecipeCategories(
            recipeId: 'r1',
            categories: any(named: 'categories'),
            groupId: any(named: 'groupId'),
          )).thenAnswer((_) async {});
      when(() => remote.saveRecipeIngredients(
            recipeId: 'r1',
            ingredients: any(named: 'ingredients'),
          )).thenAnswer((_) async {});
      // act
      await repository.updateRecipe(recipe, file);

      // assert
      verify(() => storage.deleteImage(recipe.imageUrl!)).called(1);
      verify(() => storage.uploadImage(any<File>(), any())).called(1);
      verify(() => remote.updateRecipe("r1", any())).called(1);
      verify(() => remote.deleteRecipeCategories('r1')).called(1);
      verify(() => remote.deleteRecipeIngredients('r1')).called(1);
      verify(() => remote.saveRecipeCategories(
            recipeId: 'r1',
            categories: any(named: 'categories'),
            groupId: any(named: 'groupId'),
          )).called(1);
      verify(() => remote.saveRecipeIngredients(
            recipeId: 'r1',
            ingredients: any(named: 'ingredients'),
          )).called(1);
    });
  });

  group("saveRecipe", () {
    test("save a recipe without an image", () async {
      // arrange
      final recipe = Recipe(
        id: null,
        name: 'Pasta',
        ingredientSections: [],
        categories: [],
        portions: 2,
        instructions: '',
      );

      when(() => remote.insertRecipe(
          recipeId: any(named: "recipeId"),
          model: any<RecipeModel>(named: "model"),
          groupId: any(named: "groupId"),
          createdBy: any(named: "createdBy"),
          imageUrl: any(named: "imageUrl"))).thenAnswer((_) async {});
      when(() => remote.saveRecipeCategories(
          recipeId: any(named: "recipeId"),
          categories: any(named: "categories"),
          groupId: any(named: "groupId"))).thenAnswer((_) async {});
      when(() => remote.saveRecipeIngredients(
          recipeId: any(named: "recipeId"),
          ingredients: any(named: "ingredients"))).thenAnswer((_) async {});
      // act
      final result = await repository.saveRecipe(recipe, null, 'user-1');

      // assert
      expect(result, isNotEmpty);
      verifyNever(() => storage.uploadImage(any<File>(), any()));
      verify(() => remote.insertRecipe(
            recipeId: any(named: 'recipeId'),
            model: any<RecipeModel>(named: 'model'),
            groupId: any(named: 'groupId'),
            createdBy: any(named: 'createdBy'),
            imageUrl: null,
          )).called(1);
      verify(() => remote.saveRecipeCategories(
            recipeId: any(named: 'recipeId'),
            categories: any(named: 'categories'),
            groupId: any(named: 'groupId'),
          )).called(1);
      verify(() => remote.saveRecipeIngredients(
            recipeId: any(named: 'recipeId'),
            ingredients: any(named: 'ingredients'),
          )).called(1);
    });

    test("save a recipe with an image", () async {
      // arrange
      final recipe = Recipe(
        id: null,
        name: 'Pasta',
        ingredientSections: [],
        categories: [],
        portions: 2,
        instructions: '',
      );

      when(() => remote.insertRecipe(
          recipeId: any(named: "recipeId"),
          model: any<RecipeModel>(named: "model"),
          groupId: any(named: "groupId"),
          createdBy: any(named: "createdBy"),
          imageUrl: any(named: "imageUrl"))).thenAnswer((_) async {});
      when(() => remote.saveRecipeCategories(
          recipeId: any(named: "recipeId"),
          categories: any(named: "categories"),
          groupId: any(named: "groupId"))).thenAnswer((_) async {});
      when(() => remote.saveRecipeIngredients(
          recipeId: any(named: "recipeId"),
          ingredients: any(named: "ingredients"))).thenAnswer((_) async {});
      when(() => storage.uploadImage(any<File>(), any()))
          .thenAnswer((_) async => "imageUrl");
      // act
      final result =
          await repository.saveRecipe(recipe, File("dummy"), 'user-1');

      // assert
      expect(result, isNotEmpty);
      verify(() => storage.uploadImage(any<File>(), any())).called(1);
      verify(() => remote.insertRecipe(
            recipeId: any(named: 'recipeId'),
            model: any<RecipeModel>(named: 'model'),
            groupId: any(named: 'groupId'),
            createdBy: any(named: 'createdBy'),
            imageUrl: any(named: "imageUrl"),
          )).called(1);
      verify(() => remote.saveRecipeCategories(
            recipeId: any(named: 'recipeId'),
            categories: any(named: 'categories'),
            groupId: any(named: 'groupId'),
          )).called(1);
      verify(() => remote.saveRecipeIngredients(
            recipeId: any(named: 'recipeId'),
            ingredients: any(named: 'ingredients'),
          )).called(1);
    });

    test("throws RecipeCreationException when insertRecipe fails", () async {
      // arrange
      final recipe = Recipe(
        id: null,
        name: 'Pasta',
        ingredientSections: [],
        categories: [],
        portions: 2,
        instructions: '',
      );

      when(() => remote.insertRecipe(
              recipeId: any(named: "recipeId"),
              model: any<RecipeModel>(named: "model"),
              groupId: any(named: "groupId"),
              createdBy: any(named: "createdBy"),
              imageUrl: any(named: "imageUrl")))
          .thenThrow(RecipeCreationException("boom"));

      // act && assert
      expect(
        repository.saveRecipe(recipe, null, 'user-1'),
        throwsA(isA<RecipeCreationException>()),
      );
    });

    test("throws RecipeCreationException when image upload fails", () async {
      // arrange
      final recipe = Recipe(
        id: null,
        name: 'Pasta',
        ingredientSections: [],
        categories: [],
        portions: 2,
        instructions: '',
      );

      when(() => storage.uploadImage(any<File>(), any()))
          .thenThrow(Exception('upload failed'));

      // act & assert
      expect(
        repository.saveRecipe(recipe, File('dummy'), 'user-1'),
        throwsA(isA<RecipeCreationException>()),
      );
    });
  });

  group('getRecipesByCategories — edge cases', () {
    test('returns empty list when called with empty categories list', () async {
      when(() => remote.getRecipesByCategories(
            categories: [],
            groupId: 'group-1',
          )).thenAnswer((_) async => []);

      final result = await repository.getRecipesByCategories([]);

      expect(result, isEmpty);
    });
  });

  group('updateRecipe — error cases', () {
    test('throws RecipeUpdateException when deleteImage fails', () async {
      final recipe = Recipe(
        id: 'r1',
        name: 'Pasta',
        ingredientSections: [],
        categories: [],
        portions: 2,
        instructions: '',
        imageUrl: 'old_image_url',
      );
      when(() => storage.deleteImage(any())).thenThrow(Exception('delete failed'));

      expect(
        repository.updateRecipe(recipe, File('dummy')),
        throwsA(isA<RecipeUpdateException>()),
      );
    });
  });

  group('getTimersForRecipe', () {
    test('returns mapped RecipeTimer list on success', () async {
      when(() => remote.getTimersForRecipe('r1'))
          .thenAnswer((_) async => [_timerMap()]);

      final result = await repository.getTimersForRecipe('r1');

      expect(result, isA<List<RecipeTimer>>());
      expect(result.length, 1);
      expect(result.first.timerName, 'Kochen');
    });

    test('throws RecipeTimerException on datasource error', () async {
      when(() => remote.getTimersForRecipe('r1'))
          .thenThrow(Exception('boom'));

      expect(
        repository.getTimersForRecipe('r1'),
        throwsA(isA<RecipeTimerException>()),
      );
    });
  });

  group('upsertTimer', () {
    test('returns mapped RecipeTimer on success', () async {
      when(() => remote.upsertTimer(any())).thenAnswer((_) async => _timerMap());

      final result = await repository.upsertTimer(_fakeTimer());

      expect(result, isA<RecipeTimer>());
      expect(result.timerName, 'Kochen');
    });

    test('throws RecipeTimerException on datasource error', () async {
      when(() => remote.upsertTimer(any())).thenThrow(Exception('boom'));

      expect(
        repository.upsertTimer(_fakeTimer()),
        throwsA(isA<RecipeTimerException>()),
      );
    });
  });

  group('deleteTimer', () {
    test('calls remote.deleteTimer on success', () async {
      when(() => remote.deleteTimer('r1', 0)).thenAnswer((_) async {});

      await repository.deleteTimer('r1', 0);

      verify(() => remote.deleteTimer('r1', 0)).called(1);
    });

    test('throws RecipeTimerException on datasource error', () async {
      when(() => remote.deleteTimer('r1', 0)).thenThrow(Exception('boom'));

      expect(
        repository.deleteTimer('r1', 0),
        throwsA(isA<RecipeTimerException>()),
      );
    });
  });
}
