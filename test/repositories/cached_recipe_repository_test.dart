import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/meal_plan_dao.dart';
import 'package:meal_planner/core/database/daos/recipe_cache_dao.dart';
import 'package:meal_planner/data/repositories/cached_recipe_repository.dart';
import 'package:meal_planner/data/repositories/supabase_recipe_repository.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:mocktail/mocktail.dart';

// ==================== Mocks ====================

class MockSupabaseRecipeRepository extends Mock
    implements SupabaseRecipeRepository {}

class MockRecipeCacheDao extends Mock implements RecipeCacheDao {}

class MockMealPlanDao extends Mock implements MealPlanDao {}

class _LocalRecipesCompanionFake extends Fake
    implements LocalRecipesCompanion {}

// ==================== Hilfsmethoden ====================

Recipe _fakeRecipe({String id = 'r1', String name = 'Pasta'}) => Recipe(
      id: id,
      name: name,
      ingredientSections: [],
      categories: [],
      portions: 2,
      instructions: '',
    );

LocalRecipe _fakeLocalRecipe({String id = 'r1', String name = 'Pasta'}) =>
    LocalRecipe(
      id: id,
      groupId: 'gruppe-1',
      name: name,
      portions: 2,
      instructions: '',
      createdAt: DateTime(2024),
      categoriesJson: '[]',
      ingredientSectionsJson: '[]',
      timersJson: '[]',
      isDeleted: false,
      cachedAt: DateTime(2024),
    );

void main() {
  late MockSupabaseRecipeRepository mockRemote;
  late MockRecipeCacheDao mockDao;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(RecipeSortOption.alphabetical);
    registerFallbackValue(_LocalRecipesCompanionFake());
    registerFallbackValue(<LocalRecipesCompanion>[]);
  });

  /// Erstellt einen CachedRecipeRepository mit einer echten Riverpod-Ref
  /// aus dem Test-Container — so wird isOnlineProvider korrekt überschrieben.
  CachedRecipeRepository _buildRepo({required String groupId}) {
    final testProvider = Provider<CachedRecipeRepository>((ref) {
      return CachedRecipeRepository(
        remote: mockRemote,
        dao: mockDao,
        groupId: groupId,
        ref: ref,
      );
    });
    return container.read(testProvider);
  }

  setUp(() {
    mockRemote = MockSupabaseRecipeRepository();
    mockDao = MockRecipeCacheDao();
  });

  tearDown(() => container.dispose());

  // ==================== Offline – Gruppen-Isolation ====================

  group('Offline – DAO wird nur mit der aktiven Gruppen-ID abgefragt', () {
    setUp(() {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(false),
      ]);
    });

    test('getRecipesByCategory fragt getRecipesByGroup mit "gruppe-1" ab',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => []);

      await repo.getRecipesByCategoryId(
        categoryId: '',
        offset: 0,
        limit: 20,
        sortOption: RecipeSortOption.alphabetical,
        isDeleted: false,
      );

      verify(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).called(1);
    });

    test('getRecipesByCategory mit "gruppe-2" fragt nie "gruppe-1" ab',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-2');
      when(() => mockDao.getRecipesByGroup(
            'gruppe-2',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => []);

      await repo.getRecipesByCategoryId(
        categoryId: '',
        offset: 0,
        limit: 20,
        sortOption: RecipeSortOption.alphabetical,
        isDeleted: false,
      );

      verifyNever(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          ));
    });

    test(
        'getRecipesByCategories fragt getRecipesByGroup mit der aktiven Gruppen-ID ab',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => []);

      await repo.getRecipesByCategories(['pasta', 'salad']);

      verify(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).called(1);
    });

    test(
        'getAllCategories fragt getRecipesByGroup mit der aktiven Gruppen-ID ab',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => []);

      await repo.getAllCategories();

      verify(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).called(1);
    });

    test(
        'leere Gruppen-ID (kein Beitritt) fragt nie mit einer echten Gruppen-ID ab',
        () async {
      final repo = _buildRepo(groupId: ''); // user hat keine Gruppe
      when(() => mockDao.getRecipesByGroup(
            '',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => []);

      await repo.getRecipesByCategoryId(
        categoryId: '',
        offset: 0,
        limit: 20,
        sortOption: RecipeSortOption.alphabetical,
        isDeleted: false,
      );

      // Kein Zugriff auf Rezepte einer fremden Gruppe
      verifyNever(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          ));
    });
  });

  // ==================== Online – Remote, kein Cache-Read ====================

  group('Online – Remote wird genutzt, DAO-Cache wird nicht gelesen', () {
    setUp(() {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(true),
      ]);
    });

    test('getRecipesByCategory online: Remote-Aufruf, kein getRecipesByGroup',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockRemote.getRecipesByCategoryId(
            categoryId: any(named: 'categoryId'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            sortOption: any(named: 'sortOption'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => []);
      when(() => mockDao.replaceAllForGroup(any(), any()))
          .thenAnswer((_) async {});

      await repo.getRecipesByCategoryId(
        categoryId: '',
        offset: 0,
        limit: 20,
        sortOption: RecipeSortOption.alphabetical,
        isDeleted: false,
      );

      verify(() => mockRemote.getRecipesByCategoryId(
            categoryId: any(named: 'categoryId'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            sortOption: any(named: 'sortOption'),
            isDeleted: any(named: 'isDeleted'),
          )).called(1);

      // Kein direkter DAO-Read – Rezepte kommen vom Remote
      verifyNever(() => mockDao.getRecipesByGroup(
            any(),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          ));
    });

    test('getRecipesByCategories online: Remote-Aufruf, kein getRecipesByGroup',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockRemote.getRecipesByCategories(any()))
          .thenAnswer((_) async => []);
      when(() => mockDao.upsertRecipe(any())).thenAnswer((_) async {});

      await repo.getRecipesByCategories(['pasta']);

      verify(() => mockRemote.getRecipesByCategories(any())).called(1);
      verifyNever(() => mockDao.getRecipesByGroup(
            any(),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          ));
    });

    test('geladene Rezepte werden nach dem Online-Abruf im Cache gespeichert',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      final recipe = _fakeRecipe();

      when(() => mockRemote.getRecipesByCategoryId(
            categoryId: any(named: 'categoryId'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            sortOption: any(named: 'sortOption'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => [recipe]);
      when(() => mockDao.replaceAllForGroup(any(), any()))
          .thenAnswer((_) async {});

      await repo.getRecipesByCategoryId(
        categoryId: '',
        offset: 0,
        limit: 20,
        sortOption: RecipeSortOption.alphabetical,
        isDeleted: false,
      );

      // Hintergrundcaching abwarten
      await Future.delayed(Duration.zero);

      verify(() => mockDao.replaceAllForGroup('gruppe-1', any())).called(1);
      verifyNever(() => mockDao.upsertRecipe(any()));
    });

    test('Online-Fehler löst Fallback auf Cache mit aktiver Gruppen-ID aus',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');

      when(() => mockRemote.getRecipesByCategoryId(
            categoryId: any(named: 'categoryId'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            sortOption: any(named: 'sortOption'),
            isDeleted: any(named: 'isDeleted'),
          )).thenThrow(Exception('Netzwerkfehler'));
      when(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => []);

      await repo.getRecipesByCategoryId(
        categoryId: '',
        offset: 0,
        limit: 20,
        sortOption: RecipeSortOption.alphabetical,
        isDeleted: false,
      );

      // Nach Remote-Fehler: Fallback auf Cache – aber nur für "gruppe-1"
      verify(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).called(1);
      verifyNever(() => mockDao.getRecipesByGroup(
            'gruppe-2',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          ));
    });

    test('Vollsync entfernt gecachte Rezepte, die remote gelöscht wurden',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      // Remote gibt nur noch 1 Rezept zurück — ein anderes wurde zwischenzeitlich gelöscht
      final remaining = _fakeRecipe(id: 'r1', name: 'Pasta');

      when(() => mockRemote.getRecipesByCategoryId(
            categoryId: any(named: 'categoryId'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            sortOption: any(named: 'sortOption'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => [remaining]);
      when(() => mockDao.replaceAllForGroup(any(), any()))
          .thenAnswer((_) async {});

      await repo.getRecipesByCategoryId(
        categoryId: '',
        offset: 0,
        limit: 20,
        sortOption: RecipeSortOption.alphabetical,
        isDeleted: false,
      );

      await Future.delayed(Duration.zero);

      // Atomischer Ersatz — gelöschte Einträge werden mit entfernt
      verify(() => mockDao.replaceAllForGroup('gruppe-1', any())).called(1);
      // Kein additives upsert beim vollen Sync
      verifyNever(() => mockDao.upsertRecipe(any()));
    });

    test(
        'getRecipesByCategory mit offset>0 macht additives Caching (kein replaceAll)',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      final recipe = _fakeRecipe(id: 'r2', name: 'Pizza');

      when(() => mockRemote.getRecipesByCategoryId(
            categoryId: any(named: 'categoryId'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            sortOption: any(named: 'sortOption'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => [recipe]);
      when(() => mockDao.upsertRecipe(any())).thenAnswer((_) async {});

      await repo.getRecipesByCategoryId(
        categoryId: '',
        offset: 20,
        limit: 20,
        sortOption: RecipeSortOption.alphabetical,
        isDeleted: false,
      );

      await Future.delayed(Duration.zero);

      // Folgeseite → additives Caching
      verify(() => mockDao.upsertRecipe(any())).called(1);
      verifyNever(() => mockDao.replaceAllForGroup(any(), any()));
    });
  });

  // ==================== deleteRecipe ====================

  group('deleteRecipe', () {
    late MockMealPlanDao mockMealPlanDao;

    setUp(() {
      mockMealPlanDao = MockMealPlanDao();
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(true),
        mealPlanDaoProvider.overrideWithValue(mockMealPlanDao),
      ]);
    });

    test('detaches meal plan entries, deletes remote, clears cache', () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipeById('r1'))
          .thenAnswer((_) async => _fakeLocalRecipe(id: 'r1', name: 'Pasta'));
      when(() => mockMealPlanDao.detachRecipeEntries('r1', 'Pasta'))
          .thenAnswer((_) async {});
      when(() => mockRemote.deleteRecipe('r1')).thenAnswer((_) async {});
      when(() => mockDao.deleteRecipe('r1')).thenAnswer((_) async {});

      await repo.deleteRecipe('r1');

      verifyInOrder([
        () => mockMealPlanDao.detachRecipeEntries('r1', 'Pasta'),
        () => mockRemote.deleteRecipe('r1'),
        () => mockDao.deleteRecipe('r1'),
      ]);
    });

    test('skips detach when recipe is not in local cache', () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipeById('r1')).thenAnswer((_) async => null);
      when(() => mockRemote.deleteRecipe('r1')).thenAnswer((_) async {});
      when(() => mockDao.deleteRecipe('r1')).thenAnswer((_) async {});

      await repo.deleteRecipe('r1');

      verifyNever(() => mockMealPlanDao.detachRecipeEntries(any(), any()));
      verify(() => mockRemote.deleteRecipe('r1')).called(1);
      verify(() => mockDao.deleteRecipe('r1')).called(1);
    });
  });
}
