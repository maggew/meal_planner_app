import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/recipe_cache_dao.dart';
import 'package:meal_planner/data/datasources/recipe_remote_datasource.dart';
import 'package:meal_planner/data/repositories/supabase_trash_repository.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/exceptions/recipe_exceptions.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRemoteDataSource extends Mock implements RecipeRemoteDatasource {}

class MockStorageRepository extends Mock implements StorageRepository {}

class MockRecipeCacheDao extends Mock implements RecipeCacheDao {}

class _LocalRecipesCompanionFake extends Fake implements LocalRecipesCompanion {}

// Minimal valid Supabase recipe map for use in tests
Map<String, dynamic> _recipeMap({
  String id = 'r1',
  String? imageUrl,
}) =>
    {
      'id': id,
      'title': 'Pasta',
      'instructions': 'Cook it',
      'portions': 2,
      'image_url': imageUrl,
      'recipe_categories': [],
      'recipe_ingredients': [],
    };

void main() {
  late MockRecipeRemoteDataSource remote;
  late MockStorageRepository storage;
  late MockRecipeCacheDao dao;
  late SupabaseTrashRepository repository;

  setUp(() {
    remote = MockRecipeRemoteDataSource();
    storage = MockStorageRepository();
    dao = MockRecipeCacheDao();

    repository = SupabaseTrashRepository(
      remote: remote,
      storage: storage,
      dao: dao,
      groupId: 'group-1',
    );

    registerFallbackValue(_LocalRecipesCompanionFake());
  });

  // ---------------------------------------------------------------------------
  // getDeletedRecipes
  // ---------------------------------------------------------------------------

  group('getDeletedRecipes', () {
    test('returns mapped recipes when datasource returns data', () async {
      when(() => remote.getDeletedRecipes(
            groupId: 'group-1',
            offset: 0,
            limit: 20,
          )).thenAnswer((_) async => [
            _recipeMap(id: 'r1'),
            _recipeMap(id: 'r2'),
          ]);

      final result = await repository.getDeletedRecipes(offset: 0, limit: 20);

      expect(result, isA<List<Recipe>>());
      expect(result.length, 2);
      expect(result.first.id, 'r1');
      expect(result.last.id, 'r2');
    });

    test('returns empty list when datasource returns empty list', () async {
      when(() => remote.getDeletedRecipes(
            groupId: 'group-1',
            offset: 0,
            limit: 20,
          )).thenAnswer((_) async => []);

      final result = await repository.getDeletedRecipes(offset: 0, limit: 20);

      expect(result, isEmpty);
    });

    test('returns empty list silently when datasource throws', () async {
      when(() => remote.getDeletedRecipes(
            groupId: any(named: 'groupId'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenThrow(Exception('network error'));

      final result = await repository.getDeletedRecipes(offset: 0, limit: 20);

      expect(result, isEmpty);
    });

    test('passes correct offset and limit to datasource', () async {
      when(() => remote.getDeletedRecipes(
            groupId: 'group-1',
            offset: 40,
            limit: 10,
          )).thenAnswer((_) async => []);

      await repository.getDeletedRecipes(offset: 40, limit: 10);

      verify(() => remote.getDeletedRecipes(
            groupId: 'group-1',
            offset: 40,
            limit: 10,
          )).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // restoreRecipe
  // ---------------------------------------------------------------------------

  group('restoreRecipe', () {
    test('calls remote.restoreRecipe and caches recipe in local DB', () async {
      when(() => remote.restoreRecipe('r1')).thenAnswer((_) async {});
      when(() => remote.getRecipeById(recipeId: 'r1', groupId: 'group-1'))
          .thenAnswer((_) async => _recipeMap(id: 'r1'));
      when(() => remote.getTimersForRecipe('r1')).thenAnswer((_) async => []);
      when(() => dao.upsertRecipe(any())).thenAnswer((_) async {});

      await repository.restoreRecipe('r1');

      verify(() => remote.restoreRecipe('r1')).called(1);
      verify(() => remote.getRecipeById(recipeId: 'r1', groupId: 'group-1'))
          .called(1);
      verify(() => dao.upsertRecipe(any())).called(1);
    });

    test('skips caching when getRecipeById returns null', () async {
      when(() => remote.restoreRecipe('r1')).thenAnswer((_) async {});
      when(() => remote.getRecipeById(recipeId: 'r1', groupId: 'group-1'))
          .thenAnswer((_) async => null);

      await repository.restoreRecipe('r1');

      verify(() => remote.restoreRecipe('r1')).called(1);
      verifyNever(() => dao.upsertRecipe(any()));
    });

    test('silently swallows cache update error without rethrowing', () async {
      when(() => remote.restoreRecipe('r1')).thenAnswer((_) async {});
      when(() => remote.getRecipeById(recipeId: 'r1', groupId: 'group-1'))
          .thenThrow(Exception('cache fetch failed'));

      // must not throw
      await expectLater(repository.restoreRecipe('r1'), completes);
      verifyNever(() => dao.upsertRecipe(any()));
    });

    test('throws RecipeUpdateException when remote.restoreRecipe fails',
        () async {
      when(() => remote.restoreRecipe('r1'))
          .thenThrow(Exception('restore failed'));

      await expectLater(
        repository.restoreRecipe('r1'),
        throwsA(isA<RecipeUpdateException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // hardDeleteRecipe
  // ---------------------------------------------------------------------------

  group('hardDeleteRecipe', () {
    test('deletes image, categories, ingredients, timers and local cache entry',
        () async {
      when(() => remote.getRecipeById(recipeId: 'r1', groupId: 'group-1'))
          .thenAnswer((_) async => _recipeMap(imageUrl: 'image.png'));
      when(() => storage.deleteImage('image.png')).thenAnswer((_) async {});
      when(() => remote.deleteRecipeCategories('r1')).thenAnswer((_) async {});
      when(() => remote.deleteRecipeIngredients('r1')).thenAnswer((_) async {});
      when(() => remote.deleteTimersForRecipe('r1')).thenAnswer((_) async {});
      when(() => remote.hardDeleteRecipe('r1')).thenAnswer((_) async {});
      when(() => dao.deleteRecipe('r1')).thenAnswer((_) async {});

      await repository.hardDeleteRecipe('r1');

      verify(() => storage.deleteImage('image.png')).called(1);
      verify(() => remote.deleteRecipeCategories('r1')).called(1);
      verify(() => remote.deleteRecipeIngredients('r1')).called(1);
      verify(() => remote.deleteTimersForRecipe('r1')).called(1);
      verify(() => remote.hardDeleteRecipe('r1')).called(1);
      verify(() => dao.deleteRecipe('r1')).called(1);
    });

    test('skips image deletion when image_url is null', () async {
      when(() => remote.getRecipeById(recipeId: 'r1', groupId: 'group-1'))
          .thenAnswer((_) async => _recipeMap(imageUrl: null));
      when(() => remote.deleteRecipeCategories('r1')).thenAnswer((_) async {});
      when(() => remote.deleteRecipeIngredients('r1')).thenAnswer((_) async {});
      when(() => remote.deleteTimersForRecipe('r1')).thenAnswer((_) async {});
      when(() => remote.hardDeleteRecipe('r1')).thenAnswer((_) async {});
      when(() => dao.deleteRecipe('r1')).thenAnswer((_) async {});

      await repository.hardDeleteRecipe('r1');

      verifyNever(() => storage.deleteImage(any()));
      verify(() => remote.hardDeleteRecipe('r1')).called(1);
    });

    test('skips image deletion when image_url is empty string', () async {
      when(() => remote.getRecipeById(recipeId: 'r1', groupId: 'group-1'))
          .thenAnswer((_) async => _recipeMap(imageUrl: ''));
      when(() => remote.deleteRecipeCategories('r1')).thenAnswer((_) async {});
      when(() => remote.deleteRecipeIngredients('r1')).thenAnswer((_) async {});
      when(() => remote.deleteTimersForRecipe('r1')).thenAnswer((_) async {});
      when(() => remote.hardDeleteRecipe('r1')).thenAnswer((_) async {});
      when(() => dao.deleteRecipe('r1')).thenAnswer((_) async {});

      await repository.hardDeleteRecipe('r1');

      verifyNever(() => storage.deleteImage(any()));
      verify(() => remote.hardDeleteRecipe('r1')).called(1);
    });

    test('skips image deletion when getRecipeById returns null', () async {
      when(() => remote.getRecipeById(recipeId: 'r1', groupId: 'group-1'))
          .thenAnswer((_) async => null);
      when(() => remote.deleteRecipeCategories('r1')).thenAnswer((_) async {});
      when(() => remote.deleteRecipeIngredients('r1')).thenAnswer((_) async {});
      when(() => remote.deleteTimersForRecipe('r1')).thenAnswer((_) async {});
      when(() => remote.hardDeleteRecipe('r1')).thenAnswer((_) async {});
      when(() => dao.deleteRecipe('r1')).thenAnswer((_) async {});

      await repository.hardDeleteRecipe('r1');

      verifyNever(() => storage.deleteImage(any()));
      verify(() => remote.hardDeleteRecipe('r1')).called(1);
    });

    test('throws RecipeDeletionException on error', () async {
      when(() => remote.getRecipeById(recipeId: 'r1', groupId: 'group-1'))
          .thenAnswer((_) async => null);
      when(() => remote.deleteRecipeCategories('r1')).thenAnswer((_) async {});
      when(() => remote.deleteRecipeIngredients('r1')).thenAnswer((_) async {});
      when(() => remote.deleteTimersForRecipe('r1')).thenAnswer((_) async {});
      when(() => remote.hardDeleteRecipe('r1')).thenThrow(Exception('boom'));

      await expectLater(
        repository.hardDeleteRecipe('r1'),
        throwsA(isA<RecipeDeletionException>()),
      );
    });
  });
}
