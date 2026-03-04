import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/database/converters/recipe_cache_converter.dart';
import 'package:meal_planner/core/database/daos/recipe_cache_dao.dart';
import 'package:meal_planner/data/repositories/supabase_recipe_repository.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';

const Duration _staleDuration = Duration(minutes: 5);
const int _fullSyncLimit = 2000;

class CachedRecipeRepository implements RecipeRepository {
  final SupabaseRecipeRepository _remote;
  final RecipeCacheDao _dao;
  final String _groupId;
  final Ref _ref;

  CachedRecipeRepository({
    required SupabaseRecipeRepository remote,
    required RecipeCacheDao dao,
    required String groupId,
    required Ref ref,
  })  : _remote = remote,
        _dao = dao,
        _groupId = groupId,
        _ref = ref;

  bool get _isOnline => _ref.read(isOnlineProvider);

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
    required int offset,
    required int limit,
    required RecipeSortOption sortOption,
    required bool isDeleted,
  }) async {
    if (_isOnline) {
      try {
        // Full sync: no category filter + first page → fetch all and atomically
        // replace the group cache so remote-deleted recipes are purged locally.
        if (categoryId.isEmpty && offset == 0) {
          final allRecipes = await _remote.getRecipesByCategoryId(
            categoryId: categoryId,
            offset: 0,
            limit: _fullSyncLimit,
            sortOption: sortOption,
            isDeleted: isDeleted,
          );

          // Atomically replace cache in background
          _replaceGroupCache(allRecipes);

          return allRecipes.take(limit).toList();
        }

        // Paginated or filtered fetch — additive cache update
        final recipes = await _remote.getRecipesByCategoryId(
          categoryId: categoryId,
          offset: offset,
          limit: limit,
          sortOption: sortOption,
          isDeleted: isDeleted,
        );

        // Cache results in background (don't await to avoid slowing UI)
        _cacheRecipeList(recipes);

        return recipes;
      } catch (e) {
        log('Supabase fetch failed, falling back to cache', error: e);
        return _getFromCacheFiltered(
          category: categoryId,
          isDeleted: isDeleted,
          offset: offset,
          limit: limit,
          sortOption: sortOption,
        );
      }
    }

    // Offline — serve from cache
    return _getFromCacheFiltered(
      category: categoryId,
      isDeleted: isDeleted,
      offset: offset,
      limit: limit,
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
    final cached = await _dao.getRecipesByGroup(
      _groupId,
      limit: 1000,
      offset: 0,
      isDeleted: false,
    );

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
    final cached = await _dao.getRecipesByGroup(
      _groupId,
      limit: 1000,
      offset: 0,
      isDeleted: false,
    );

    final categories = <String>{};
    for (final row in cached) {
      final recipe = RecipeCacheConverter.toRecipe(row);
      categories.addAll(recipe.categories);
    }
    return categories.toList()..sort();
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

  Future<void> _replaceGroupCache(List<Recipe> recipes) async {
    try {
      final companions = recipes
          .where((r) => r.id != null)
          .map((r) => RecipeCacheConverter.toCompanion(r,
              groupId: _groupId, timers: []))
          .toList();
      await _dao.replaceAllForGroup(_groupId, companions);
    } catch (e) {
      log('Failed to replace group cache for $_groupId', error: e);
    }
  }

  Future<List<Recipe>> _getFromCacheFiltered({
    required String category,
    required bool isDeleted,
    required int offset,
    required int limit,
    required RecipeSortOption sortOption,
  }) async {
    final cached = await _dao.getRecipesByGroup(
      _groupId,
      limit: 1000,
      offset: 0,
      isDeleted: isDeleted,
    );

    var recipes = cached.map(RecipeCacheConverter.toRecipe).toList();

    // Filter by category (empty = "Alle")
    if (category.isNotEmpty) {
      recipes = recipes
          .where((r) => r.categories
              .any((c) => c.toLowerCase() == category.toLowerCase()))
          .toList();
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

    // Paginate
    if (offset >= recipes.length) return [];
    final end = (offset + limit).clamp(0, recipes.length);
    return recipes.sublist(offset, end);
  }
}
