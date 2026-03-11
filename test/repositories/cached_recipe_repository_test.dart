import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/meal_plan_dao.dart';
import 'package:meal_planner/core/database/daos/recipe_cache_dao.dart';
import 'package:meal_planner/data/repositories/cached_recipe_repository.dart';
import 'package:meal_planner/data/repositories/supabase_recipe_repository.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
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

RecipeTimer _fakeTimer({String recipeId = 'r1'}) => RecipeTimer(
      recipeId: recipeId,
      stepIndex: 0,
      timerName: 'Kochen',
      durationSeconds: 300,
    );

// ==================== Hilfsmethoden ====================

Recipe _fakeRecipe({String id = 'r1', String name = 'Pasta'}) => Recipe(
      id: id,
      name: name,
      ingredientSections: [],
      categories: [],
      portions: 2,
      instructions: '',
    );

LocalRecipe _fakeLocalRecipe({
  String id = 'r1',
  String name = 'Pasta',
  DateTime? createdAt,
  String categoriesJson = '[]',
}) =>
    LocalRecipe(
      id: id,
      groupId: 'gruppe-1',
      name: name,
      portions: 2,
      instructions: '',
      createdAt: createdAt ?? DateTime(2024),
      categoriesJson: categoriesJson,
      ingredientSectionsJson: '[]',
      timersJson: '[]',
      carbTagsJson: '[]',
      isDeleted: false,
      cachedAt: DateTime(2024),
    );

/// Fresh local recipe — cachedAt = now, so staleness check passes.
LocalRecipe _freshLocalRecipe({String id = 'r1', String name = 'Pasta'}) =>
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
      carbTagsJson: '[]',
      isDeleted: false,
      cachedAt: DateTime.now(),
    );

void main() {
  late MockSupabaseRecipeRepository mockRemote;
  late MockRecipeCacheDao mockDao;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(RecipeSortOption.alphabetical);
    registerFallbackValue(_LocalRecipesCompanionFake());
    registerFallbackValue(<LocalRecipesCompanion>[]);
    registerFallbackValue(_fakeRecipe());
    registerFallbackValue(_fakeTimer());
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

    test('getRecipesByCategories online error → Fallback auf Cache', () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockRemote.getRecipesByCategories(any()))
          .thenThrow(Exception('Netzwerkfehler'));
      when(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => []);

      await repo.getRecipesByCategories(['pasta']);

      verify(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).called(1);
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

    test('replaceAllForGroup wirft → catch-Block, Remote-Ergebnis wird trotzdem zurückgegeben',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      final recipe = _fakeRecipe(id: 'r1');
      when(() => mockRemote.getRecipesByCategoryId(
            categoryId: any(named: 'categoryId'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            sortOption: any(named: 'sortOption'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => [recipe]);
      when(() => mockDao.replaceAllForGroup(any(), any()))
          .thenThrow(Exception('db error'));

      final result = await repo.getRecipesByCategoryId(
        categoryId: '',
        offset: 0,
        limit: 20,
        sortOption: RecipeSortOption.alphabetical,
        isDeleted: false,
      );

      await Future.delayed(Duration.zero);

      expect(result, hasLength(1));
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

  // ==================== getRecipeById ====================

  group('getRecipeById', () {
    test('offline + no cache → returns null', () async {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(false),
      ]);
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipeById('r1')).thenAnswer((_) async => null);

      final result = await repo.getRecipeById('r1');

      expect(result, isNull);
    });

    test('cache hit (fresh) → returns from cache, no remote call', () async {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(false),
      ]);
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipeById('r1'))
          .thenAnswer((_) async => _freshLocalRecipe(id: 'r1'));

      final result = await repo.getRecipeById('r1');

      expect(result, isA<Recipe>());
      verifyNever(() => mockRemote.getRecipeById(any()));
    });

    test('cache miss + online → fetches remote, caches, returns', () async {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(true),
      ]);
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipeById('r1')).thenAnswer((_) async => null);
      when(() => mockRemote.getRecipeById('r1'))
          .thenAnswer((_) async => _fakeRecipe(id: 'r1'));
      when(() => mockRemote.getTimersForRecipe('r1'))
          .thenAnswer((_) async => []);
      when(() => mockDao.upsertRecipe(any())).thenAnswer((_) async {});

      final result = await repo.getRecipeById('r1');

      expect(result, isA<Recipe>());
      verify(() => mockDao.upsertRecipe(any())).called(1);
    });

    test('stale cache + offline → returns stale', () async {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(false),
      ]);
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipeById('r1'))
          .thenAnswer((_) async => _fakeLocalRecipe(id: 'r1')); // stale

      final result = await repo.getRecipeById('r1');

      expect(result, isA<Recipe>());
      verifyNever(() => mockRemote.getRecipeById(any()));
    });

    test('stale cache + online + revalidation fails → returns stale',
        () async {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(true),
      ]);
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipeById('r1'))
          .thenAnswer((_) async => _fakeLocalRecipe(id: 'r1')); // stale
      when(() => mockRemote.getRecipeById('r1'))
          .thenThrow(Exception('network error'));

      final result = await repo.getRecipeById('r1');

      expect(result, isA<Recipe>());
    });
  });

  // ==================== saveRecipe ====================

  group('saveRecipe', () {
    test('returns recipeId even if cache re-fetch fails', () async {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(true),
      ]);
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockRemote.saveRecipe(any(), any(), any()))
          .thenAnswer((_) async => 'new-id');
      when(() => mockRemote.getRecipeById('new-id'))
          .thenThrow(Exception('re-fetch failed'));

      final result = await repo.saveRecipe(_fakeRecipe(), null, 'user-1');

      expect(result, 'new-id');
    });

    test('upsertRecipe wirft → catch-Block in _cacheRecipe, recipeId wird trotzdem zurückgegeben',
        () async {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(true),
      ]);
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockRemote.saveRecipe(any(), any(), any()))
          .thenAnswer((_) async => 'new-id');
      when(() => mockRemote.getRecipeById('new-id'))
          .thenAnswer((_) async => _fakeRecipe(id: 'new-id'));
      when(() => mockDao.upsertRecipe(any()))
          .thenThrow(Exception('db error'));

      final result = await repo.saveRecipe(_fakeRecipe(), null, 'user-1');

      expect(result, 'new-id');
      verify(() => mockDao.upsertRecipe(any())).called(1);
    });

    test('caches recipe when re-fetch succeeds', () async {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(true),
      ]);
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockRemote.saveRecipe(any(), any(), any()))
          .thenAnswer((_) async => 'new-id');
      when(() => mockRemote.getRecipeById('new-id'))
          .thenAnswer((_) async => _fakeRecipe(id: 'new-id'));
      when(() => mockDao.upsertRecipe(any())).thenAnswer((_) async {});

      final result = await repo.saveRecipe(_fakeRecipe(), null, 'user-1');

      expect(result, 'new-id');
      verify(() => mockDao.upsertRecipe(any())).called(1);
    });
  });

  // ==================== Offline edge cases ====================

  group('Offline – getRecipesByCategories edge cases', () {
    setUp(() {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(false),
      ]);
    });

    test('case-insensitive category match', () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => [
            LocalRecipe(
              id: 'r1',
              groupId: 'gruppe-1',
              name: 'Pasta Bolognese',
              portions: 2,
              instructions: '',
              createdAt: DateTime(2024),
              categoriesJson: '["Pasta"]',
              ingredientSectionsJson: '[]',
              timersJson: '[]',
              carbTagsJson: '[]',
              isDeleted: false,
              cachedAt: DateTime.now(),
            ),
          ]);

      final result = await repo.getRecipesByCategories(['pasta']); // lowercase

      expect(result, hasLength(1));
    });

    test('nicht-leere categoryId filtert gecachte Rezepte nach Kategorie',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => [
            _fakeLocalRecipe(
                id: 'r1', name: 'Pasta', categoriesJson: '["Pasta"]'),
            _fakeLocalRecipe(
                id: 'r2', name: 'Salat', categoriesJson: '["Salat"]'),
          ]);

      final result = await repo.getRecipesByCategoryId(
        categoryId: 'Pasta',
        offset: 0,
        limit: 20,
        sortOption: RecipeSortOption.alphabetical,
        isDeleted: false,
      );

      expect(result, hasLength(1));
      expect(result.first.name, 'Pasta');
    });

    test('newest sort: neuestes Rezept zuerst', () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => [
            _fakeLocalRecipe(
                id: 'r1', name: 'Alt', createdAt: DateTime(2023)),
            _fakeLocalRecipe(
                id: 'r2', name: 'Neu', createdAt: DateTime(2025)),
          ]);

      final result = await repo.getRecipesByCategoryId(
        categoryId: '',
        offset: 0,
        limit: 20,
        sortOption: RecipeSortOption.newest,
        isDeleted: false,
      );

      expect(result.first.name, 'Neu');
    });

    test('oldest sort: ältestes Rezept zuerst', () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => [
            _fakeLocalRecipe(
                id: 'r1', name: 'Neu', createdAt: DateTime(2025)),
            _fakeLocalRecipe(
                id: 'r2', name: 'Alt', createdAt: DateTime(2023)),
          ]);

      final result = await repo.getRecipesByCategoryId(
        categoryId: '',
        offset: 0,
        limit: 20,
        sortOption: RecipeSortOption.oldest,
        isDeleted: false,
      );

      expect(result.first.name, 'Alt');
    });

    test('mostCooked sort falls back to alphabetical offline', () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => [
            _fakeLocalRecipe(id: 'r2', name: 'Zucchini'),
            _fakeLocalRecipe(id: 'r1', name: 'Apple'),
          ]);

      final result = await repo.getRecipesByCategoryId(
        categoryId: '',
        offset: 0,
        limit: 20,
        sortOption: RecipeSortOption.mostCooked,
        isDeleted: false,
      );

      expect(result.first.name, 'Apple');
    });
  });

  // ==================== getTimersForRecipe ====================

  group('getTimersForRecipe', () {
    test('online: returns remote timers directly', () async {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(true),
      ]);
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockRemote.getTimersForRecipe('r1'))
          .thenAnswer((_) async => []);

      final result = await repo.getTimersForRecipe('r1');

      expect(result, isEmpty);
      verify(() => mockRemote.getTimersForRecipe('r1')).called(1);
      verifyNever(() => mockDao.getRecipeById(any()));
    });

    test('online error → fallback to cache timers', () async {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(true),
      ]);
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockRemote.getTimersForRecipe('r1'))
          .thenThrow(Exception('network error'));
      when(() => mockDao.getRecipeById('r1'))
          .thenAnswer((_) async => _fakeLocalRecipe(id: 'r1')); // timersJson='[]'

      final result = await repo.getTimersForRecipe('r1');

      expect(result, isEmpty);
    });

    test('offline + kein Cache-Eintrag → gibt leere Liste zurück', () async {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(false),
      ]);
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipeById('r1')).thenAnswer((_) async => null);

      final result = await repo.getTimersForRecipe('r1');

      expect(result, isEmpty);
    });
  });

  // ==================== deleteTimer ====================

  // ==================== upsertTimer ====================

  group('upsertTimer', () {
    setUp(() {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(true),
      ]);
    });

    test('success + Cache-Eintrag vorhanden → cached recipe wird aktualisiert',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      final timer = _fakeTimer();
      when(() => mockRemote.upsertTimer(any())).thenAnswer((_) async => timer);
      when(() => mockRemote.getTimersForRecipe('r1'))
          .thenAnswer((_) async => [timer]);
      when(() => mockDao.getRecipeById('r1'))
          .thenAnswer((_) async => _fakeLocalRecipe(id: 'r1'));
      when(() => mockDao.upsertRecipe(any())).thenAnswer((_) async {});

      final result = await repo.upsertTimer(timer);

      expect(result, timer);
      verify(() => mockDao.upsertRecipe(any())).called(1);
    });

    test('kein Cache-Eintrag → kein upsertRecipe', () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      final timer = _fakeTimer();
      when(() => mockRemote.upsertTimer(any())).thenAnswer((_) async => timer);
      when(() => mockRemote.getTimersForRecipe('r1'))
          .thenAnswer((_) async => [timer]);
      when(() => mockDao.getRecipeById('r1')).thenAnswer((_) async => null);

      final result = await repo.upsertTimer(timer);

      expect(result, timer);
      verifyNever(() => mockDao.upsertRecipe(any()));
    });

    test('getTimersForRecipe wirft → catch-Block, Ergebnis wird trotzdem zurückgegeben',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      final timer = _fakeTimer();
      when(() => mockRemote.upsertTimer(any())).thenAnswer((_) async => timer);
      when(() => mockRemote.getTimersForRecipe('r1'))
          .thenThrow(Exception('network error'));

      final result = await repo.upsertTimer(timer);

      expect(result, timer);
      verifyNever(() => mockDao.upsertRecipe(any()));
    });
  });

  group('deleteTimer', () {
    setUp(() {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(true),
      ]);
    });

    test('swallows cache-update error: completes even if getTimersForRecipe throws',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockRemote.deleteTimer('r1', 0)).thenAnswer((_) async {});
      when(() => mockRemote.getTimersForRecipe('r1'))
          .thenThrow(Exception('network error'));

      await expectLater(repo.deleteTimer('r1', 0), completes);
    });

    test('Cache-Eintrag vorhanden → cached recipe wird mit neuen Timern aktualisiert',
        () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockRemote.deleteTimer('r1', 0)).thenAnswer((_) async {});
      when(() => mockRemote.getTimersForRecipe('r1'))
          .thenAnswer((_) async => []);
      when(() => mockDao.getRecipeById('r1'))
          .thenAnswer((_) async => _fakeLocalRecipe(id: 'r1'));
      when(() => mockDao.upsertRecipe(any())).thenAnswer((_) async {});

      await repo.deleteTimer('r1', 0);

      verify(() => mockDao.upsertRecipe(any())).called(1);
    });

    test('kein Cache-Eintrag → kein upsertRecipe', () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockRemote.deleteTimer('r1', 0)).thenAnswer((_) async {});
      when(() => mockRemote.getTimersForRecipe('r1'))
          .thenAnswer((_) async => []);
      when(() => mockDao.getRecipeById('r1')).thenAnswer((_) async => null);

      await repo.deleteTimer('r1', 0);

      verifyNever(() => mockDao.upsertRecipe(any()));
    });
  });

  // ==================== updateRecipe ====================

  group('updateRecipe', () {
    setUp(() {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(true),
      ]);
    });

    test('success → ruft Remote auf, re-fetcht und cached das Rezept', () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      final recipe = _fakeRecipe(id: 'r1');
      when(() => mockRemote.updateRecipe(any(), any())).thenAnswer((_) async {});
      when(() => mockRemote.getRecipeById('r1'))
          .thenAnswer((_) async => recipe);
      when(() => mockRemote.getTimersForRecipe('r1'))
          .thenAnswer((_) async => []);
      when(() => mockDao.upsertRecipe(any())).thenAnswer((_) async {});

      await repo.updateRecipe(recipe, null);

      verify(() => mockRemote.updateRecipe(any(), any())).called(1);
      verify(() => mockDao.upsertRecipe(any())).called(1);
    });

    test('recipe.id == null → kein Re-fetch', () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      final recipe = Recipe(
        id: null,
        name: 'Pasta',
        ingredientSections: [],
        categories: [],
        portions: 2,
        instructions: '',
      );
      when(() => mockRemote.updateRecipe(any(), any())).thenAnswer((_) async {});

      await repo.updateRecipe(recipe, null);

      verify(() => mockRemote.updateRecipe(any(), any())).called(1);
      verifyNever(() => mockRemote.getRecipeById(any()));
      verifyNever(() => mockDao.upsertRecipe(any()));
    });

    test('re-fetch gibt null zurück → kein upsert', () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      final recipe = _fakeRecipe(id: 'r1');
      when(() => mockRemote.updateRecipe(any(), any())).thenAnswer((_) async {});
      when(() => mockRemote.getRecipeById('r1')).thenAnswer((_) async => null);

      await repo.updateRecipe(recipe, null);

      verifyNever(() => mockDao.upsertRecipe(any()));
    });

    test('re-fetch wirft → catch-Block, completes ohne Fehler', () async {
      final repo = _buildRepo(groupId: 'gruppe-1');
      final recipe = _fakeRecipe(id: 'r1');
      when(() => mockRemote.updateRecipe(any(), any())).thenAnswer((_) async {});
      when(() => mockRemote.getRecipeById('r1'))
          .thenThrow(Exception('network error'));

      await expectLater(repo.updateRecipe(recipe, null), completes);
      verifyNever(() => mockDao.upsertRecipe(any()));
    });
  });

  // ==================== getAllCategories ====================

  group('getAllCategories', () {
    test('online → delegiert an Remote, kein DAO-Read', () async {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(true),
      ]);
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockRemote.getAllCategories())
          .thenAnswer((_) async => ['Pasta', 'Salat']);

      final result = await repo.getAllCategories();

      expect(result, ['Pasta', 'Salat']);
      verify(() => mockRemote.getAllCategories()).called(1);
      verifyNever(() => mockDao.getRecipesByGroup(
            any(),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          ));
    });

    test('offline → extrahiert eindeutige Kategorien aus gecachten Rezepten',
        () async {
      container = ProviderContainer(overrides: [
        isOnlineProvider.overrideWithValue(false),
      ]);
      final repo = _buildRepo(groupId: 'gruppe-1');
      when(() => mockDao.getRecipesByGroup(
            'gruppe-1',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            isDeleted: any(named: 'isDeleted'),
          )).thenAnswer((_) async => [
            LocalRecipe(
              id: 'r1',
              groupId: 'gruppe-1',
              name: 'Pasta',
              portions: 2,
              instructions: '',
              createdAt: DateTime(2024),
              categoriesJson: '["Pasta","Salat"]',
              ingredientSectionsJson: '[]',
              timersJson: '[]',
              carbTagsJson: '[]',
              isDeleted: false,
              cachedAt: DateTime.now(),
            ),
            LocalRecipe(
              id: 'r2',
              groupId: 'gruppe-1',
              name: 'Suppe',
              portions: 2,
              instructions: '',
              createdAt: DateTime(2024),
              categoriesJson: '["Salat"]',
              ingredientSectionsJson: '[]',
              timersJson: '[]',
              carbTagsJson: '[]',
              isDeleted: false,
              cachedAt: DateTime.now(),
            ),
          ]);

      final result = await repo.getAllCategories();

      expect(result, containsAll(['Pasta', 'Salat']));
      expect(result, hasLength(2)); // keine Duplikate
    });
  });

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
