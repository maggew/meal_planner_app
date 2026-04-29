import 'dart:developer';
import 'dart:io';

import 'package:meal_planner/core/constants/local_keys.dart';
import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/core/database/converters/recipe_cache_converter.dart';
import 'package:meal_planner/core/database/daos/recipe_cache_dao.dart';
import 'package:meal_planner/data/repositories/supabase_recipe_repository.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Duration _staleDuration = Duration(minutes: 5);
const Duration _syncCooldown = Duration(seconds: 30);

class CachedRecipeRepository implements RecipeRepository {
  final SupabaseRecipeRepository _remote;
  final RecipeCacheDao _dao;
  final String _groupId;
  final bool Function() _isOnlineFn;
  final SharedPreferences _prefs;

  /// Resolves a category UUID to its display name. Used by the offline cache
  /// filter path. Returns null when the category cannot be resolved — in that
  /// case the filter is skipped and all cached recipes are returned.
  final Future<String?> Function(String categoryId) _resolveCategoryName;

  CachedRecipeRepository({
    required SupabaseRecipeRepository remote,
    required RecipeCacheDao dao,
    required String groupId,
    required bool Function() isOnline,
    required SharedPreferences prefs,
    required Future<String?> Function(String categoryId) resolveCategoryName,
  })  : _remote = remote,
        _dao = dao,
        _groupId = groupId,
        _isOnlineFn = isOnline,
        _prefs = prefs,
        _resolveCategoryName = resolveCategoryName;

  bool get _isOnline => _isOnlineFn();

  // ==================== READ ====================

  @override
  Future<Recipe?> getRecipeById(String recipeId) async {
    final cached = await _dao.getRecipeById(recipeId);

    if (cached != null) {
      final isFresh =
          DateTime.now().difference(cached.cachedAt) < _staleDuration;

      if (isFresh) {
        return RecipeCacheConverter.toRecipe(cached);
      }

      // Stale — try revalidating in background
      if (_isOnline) {
        try {
          final fresh = await _remote.getRecipeById(recipeId);
          if (fresh != null) {
            final timers = await _remote.getTimersForRecipe(recipeId);
            await _cacheRecipe(fresh, timers);
            return fresh;
          }
        } catch (e) {
          log('Cache revalidation failed for $recipeId', error: e);
        }
      }

      // Return stale data as fallback
      return RecipeCacheConverter.toRecipe(cached);
    }

    // Nothing in cache — must fetch
    if (_isOnline) {
      final recipe = await _remote.getRecipeById(recipeId);
      if (recipe != null) {
        final timers = await _remote.getTimersForRecipe(recipeId);
        await _cacheRecipe(recipe, timers);
      }
      return recipe;
    }

    return null;
  }

  @override
  Future<List<Recipe>> getRecipesByCategoryId({
    required String categoryId,
    required RecipeSortOption sortOption,
    required bool isDeleted,
  }) async {
    if (_isOnline) {
      try {
        final recipes = await _remote.getRecipesByCategoryId(
          categoryId: categoryId,
          sortOption: sortOption,
          isDeleted: isDeleted,
        );

        _cacheRecipeList(recipes);

        return recipes;
      } catch (e) {
        log('Supabase fetch failed, falling back to cache', error: e);
        return _getFromCacheFiltered(
          category: categoryId,
          isDeleted: isDeleted,
          sortOption: sortOption,
        );
      }
    }

    // Offline — serve from cache
    return _getFromCacheFiltered(
      category: categoryId,
      isDeleted: isDeleted,
      sortOption: sortOption,
    );
  }

  @override
  Future<List<Recipe>> getRecipesByCategories(List<String> categories) async {
    if (_isOnline) {
      try {
        final recipes = await _remote.getRecipesByCategories(categories);
        _cacheRecipeList(recipes);
        return recipes;
      } catch (e) {
        log('Supabase fetch failed, falling back to cache', error: e);
      }
    }

    // Offline fallback — filter from all cached recipes
    final cached = await _dao.getAllByGroup(_groupId);

    final categoriesLower = categories.map((c) => c.toLowerCase()).toSet();
    return cached
        .map(RecipeCacheConverter.toRecipe)
        .where((r) =>
            r.categories.any((c) => categoriesLower.contains(c.toLowerCase())))
        .toList();
  }

  @override
  Future<List<String>> getAllCategories() async {
    if (_isOnline) {
      return _remote.getAllCategories();
    }

    // Offline — extract unique categories from cache
    final cached = await _dao.getAllByGroup(_groupId);

    final categories = <String>{};
    for (final row in cached) {
      final recipe = RecipeCacheConverter.toRecipe(row);
      categories.addAll(recipe.categories);
    }
    return categories.toList()..sort();
  }

  @override
  Future<String?> getRecipeTitle(String recipeId) async {
    final cached = await _dao.getRecipeById(recipeId);
    if (cached != null) return cached.name;

    if (_isOnline) {
      try {
        return await _remote.getRecipeTitle(recipeId);
      } catch (e) {
        log('getRecipeTitle remote fallback failed for $recipeId', error: e);
      }
    }

    return null;
  }

  // ==================== WRITE (pass-through + cache update) ====================

  @override
  Future<String> saveRecipe(
      Recipe recipe, File? image, String createdBy) async {
    final recipeId = await _remote.saveRecipe(recipe, image, createdBy);

    // Re-fetch the complete recipe and cache it
    try {
      final saved = await _remote.getRecipeById(recipeId);
      if (saved != null) {
        await _cacheRecipe(saved, []);
      }
    } catch (e) {
      log('Failed to cache newly saved recipe', error: e);
    }

    return recipeId;
  }

  @override
  Future<void> updateRecipe(Recipe recipe, File? newImage) async {
    await _remote.updateRecipe(recipe, newImage);

    // Re-fetch and cache updated recipe
    try {
      if (recipe.id != null) {
        final updated = await _remote.getRecipeById(recipe.id!);
        if (updated != null) {
          final timers = await _remote.getTimersForRecipe(recipe.id!);
          await _cacheRecipe(updated, timers);
        }
      }
    } catch (e) {
      log('Failed to cache updated recipe', error: e);
    }
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    await _remote.deleteRecipe(recipeId);
    await _dao.deleteRecipe(recipeId);
  }

  // ==================== TIMER (pass-through + cache update) ====================

  @override
  Future<List<RecipeTimer>> getTimersForRecipe(String recipeId) async {
    if (_isOnline) {
      try {
        return await _remote.getTimersForRecipe(recipeId);
      } catch (e) {
        log('Failed to fetch timers from remote', error: e);
      }
    }

    // Offline fallback
    final cached = await _dao.getRecipeById(recipeId);
    if (cached != null) {
      return RecipeCacheConverter.toTimers(cached);
    }
    return [];
  }

  @override
  Future<RecipeTimer> upsertTimer(RecipeTimer timer) async {
    final result = await _remote.upsertTimer(timer);

    // Update cached timers
    try {
      final allTimers = await _remote.getTimersForRecipe(timer.recipeId);
      final cached = await _dao.getRecipeById(timer.recipeId);
      if (cached != null) {
        final recipe = RecipeCacheConverter.toRecipe(cached);
        await _cacheRecipe(recipe, allTimers);
      }
    } catch (e) {
      log('Failed to update cached timers', error: e);
    }

    return result;
  }

  @override
  Future<void> deleteTimer(String recipeId, int stepIndex) async {
    await _remote.deleteTimer(recipeId, stepIndex);

    // Update cached timers
    try {
      final allTimers = await _remote.getTimersForRecipe(recipeId);
      final cached = await _dao.getRecipeById(recipeId);
      if (cached != null) {
        final recipe = RecipeCacheConverter.toRecipe(cached);
        await _cacheRecipe(recipe, allTimers);
      }
    } catch (e) {
      log('Failed to update cached timers after delete', error: e);
    }
  }

  // ==================== TIMES COOKED ====================

  @override
  Future<void> incrementTimesCooked(String recipeId) async {
    await _remote.incrementTimesCooked(recipeId);

    // Update local cache
    try {
      final cached = await _dao.getRecipeById(recipeId);
      if (cached != null) {
        final recipe = RecipeCacheConverter.toRecipe(cached);
        final updated = recipe.copyWith(timesCooked: recipe.timesCooked + 1);
        final timers = RecipeCacheConverter.toTimers(cached);
        await _cacheRecipe(updated, timers);
      }
    } catch (e) {
      log('Failed to update cached timesCooked', error: e);
    }
  }

  // ==================== SEARCH ====================

  @override
  Future<List<Recipe>> searchRecipes(String query) async {
    final rows = await _dao.searchByName(_groupId, query);
    return rows.map(RecipeCacheConverter.toRecipe).toList();
  }

  // ==================== DELTA-SYNC ====================

  /// Syncs local Drift cache with remote Supabase data.
  /// Integration method (IOSP): orchestrates I/O, delegates logic to [computeSyncDelta].
  Future<void> deltaSync() async {
    if (!_isOnline) return;

    // Staleness check
    final syncKey = '${LocalKeys.recipeSyncPrefix}$_groupId';
    final lastSyncMs = _prefs.getInt(syncKey) ?? 0;
    final lastSync = DateTime.fromMillisecondsSinceEpoch(lastSyncMs);
    if (DateTime.now().difference(lastSync) < _syncCooldown) return;

    try {
      // 1. Fetch remote manifest (lightweight: id + updated_at)
      final remoteManifestRaw = await _remote.getRecipeManifest();
      final remoteManifest = remoteManifestRaw.map((row) => (
            id: row[SupabaseConstants.recipeId] as String,
            updatedAt: row[SupabaseConstants.recipeUpdatedAt] != null
                ? DateTime.parse(row[SupabaseConstants.recipeUpdatedAt] as String)
                : null,
          )).toList();

      // 2. Fetch local manifest
      final localManifest = await _dao.getManifest(_groupId);

      // 3. Compute delta (pure operation)
      final delta = computeSyncDelta(
        remoteManifest: remoteManifest,
        localManifest: localManifest,
      );

      // 4. Fetch and upsert changed/new recipes
      if (delta.idsToFetch.isNotEmpty) {
        final recipes = await _remote.getRecipesByIds(delta.idsToFetch);
        final remoteMap = {for (final e in remoteManifest) e.id: e.updatedAt};
        for (final recipe in recipes) {
          if (recipe.id == null) continue;
          final companion = RecipeCacheConverter.toCompanion(
            recipe,
            groupId: _groupId,
            timers: [],
            updatedAt: remoteMap[recipe.id],
          );
          await _dao.upsertRecipe(companion);
        }
      }

      // 5. Delete locally cached recipes that were removed remotely
      if (delta.idsToDelete.isNotEmpty) {
        await _dao.deleteByIds(delta.idsToDelete);
      }

      // 6. Update sync timestamp
      await _prefs.setInt(syncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      log('Delta sync failed for group $_groupId', error: e);
    }
  }

  // ==================== PRIVATE ====================

  Future<void> _cacheRecipe(Recipe recipe, List<RecipeTimer> timers) async {
    if (recipe.id == null) return;
    try {
      final companion = RecipeCacheConverter.toCompanion(
        recipe,
        groupId: _groupId,
        timers: timers,
      );
      await _dao.upsertRecipe(companion);
    } catch (e) {
      log('Failed to cache recipe ${recipe.id}', error: e);
    }
  }

  Future<void> _cacheRecipeList(List<Recipe> recipes) async {
    for (final recipe in recipes) {
      await _cacheRecipe(recipe, []);
    }
  }

  Future<List<Recipe>> _getFromCacheFiltered({
    required String category,
    required bool isDeleted,
    required RecipeSortOption sortOption,
  }) async {
    final cached = await _dao.getAllByGroup(_groupId);

    var recipes = cached.map(RecipeCacheConverter.toRecipe).toList();

    // Filter by category — resolve UUID → name via the injected callback.
    if (category.isNotEmpty) {
      final categoryName = await _resolveCategoryName(category);

      if (categoryName != null) {
        recipes = recipes
            .where((r) => r.categories
                .any((c) => c.toLowerCase() == categoryName.toLowerCase()))
            .toList();
      }
    }

    // Sort
    switch (sortOption) {
      case RecipeSortOption.alphabetical:
        recipes.sort((a, b) => a.name.compareTo(b.name));
      case RecipeSortOption.newest:
        recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case RecipeSortOption.oldest:
        recipes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case RecipeSortOption.mostCooked:
        // No times_cooked in cache — fallback to alphabetical
        recipes.sort((a, b) => a.name.compareTo(b.name));
    }

    return recipes;
  }
}

// ==================== PURE OPERATION (IOSP) ====================

/// Result of comparing remote and local manifests.
typedef SyncDelta = ({List<String> idsToFetch, List<String> idsToDelete});

/// Pure operation: compares remote and local manifests to determine which
/// recipes need to be fetched (new or updated) and which should be deleted.
SyncDelta computeSyncDelta({
  required List<({String id, DateTime? updatedAt})> remoteManifest,
  required List<({String id, DateTime? updatedAt})> localManifest,
}) {
  final remoteMap = {for (final e in remoteManifest) e.id: e.updatedAt};
  final localMap = {for (final e in localManifest) e.id: e.updatedAt};

  final idsToFetch = <String>[];
  for (final entry in remoteManifest) {
    final localUpdatedAt = localMap[entry.id];
    if (localUpdatedAt == null) {
      // New recipe — not in local cache
      idsToFetch.add(entry.id);
    } else if (entry.updatedAt != null && entry.updatedAt != localUpdatedAt) {
      // Updated recipe — timestamps differ
      idsToFetch.add(entry.id);
    }
  }

  final remoteIds = remoteMap.keys.toSet();
  final idsToDelete = localMap.keys
      .where((id) => !remoteIds.contains(id))
      .toList();

  return (idsToFetch: idsToFetch, idsToDelete: idsToDelete);
}
