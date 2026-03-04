import 'dart:developer';

import 'package:meal_planner/core/database/converters/recipe_cache_converter.dart';
import 'package:meal_planner/core/database/daos/recipe_cache_dao.dart';
import 'package:meal_planner/data/datasources/recipe_remote_datasource.dart';
import 'package:meal_planner/data/model/recipe_model.dart';
import 'package:meal_planner/data/model/recipe_timer_model.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/exceptions/recipe_exceptions.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';
import 'package:meal_planner/domain/repositories/trash_repository.dart';

class SupabaseTrashRepository implements TrashRepository {
  final RecipeRemoteDatasource _remote;
  final StorageRepository _storage;
  final RecipeCacheDao _dao;
  final String _groupId;

  SupabaseTrashRepository({
    required RecipeRemoteDatasource remote,
    required StorageRepository storage,
    required RecipeCacheDao dao,
    required String groupId,
  })  : _remote = remote,
        _storage = storage,
        _dao = dao,
        _groupId = groupId;

  @override
  Future<List<Recipe>> getDeletedRecipes({
    required int offset,
    required int limit,
  }) async {
    try {
      final data = await _remote.getDeletedRecipes(
        groupId: _groupId,
        offset: offset,
        limit: limit,
      );
      return data.map((d) => RecipeModel.fromSupabaseWithRelations(d)).toList();
    } catch (e, st) {
      log('Error fetching deleted recipes', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<void> restoreRecipe(String recipeId) async {
    try {
      await _remote.restoreRecipe(recipeId);

      // Re-fetch and update local cache
      try {
        final data = await _remote.getRecipeById(
          recipeId: recipeId,
          groupId: _groupId,
        );
        if (data != null) {
          final recipe = RecipeModel.fromSupabaseWithRelations(data);
          final timerData = await _remote.getTimersForRecipe(recipeId);
          final timers =
              timerData.map((r) => RecipeTimerModel.fromSupabase(r).toEntity()).toList();
          final companion = RecipeCacheConverter.toCompanion(
            recipe,
            groupId: _groupId,
            timers: timers,
          );
          await _dao.upsertRecipe(companion);
        }
      } catch (e) {
        log('Failed to cache restored recipe', error: e);
      }
    } catch (e) {
      throw RecipeUpdateException(e.toString());
    }
  }

  @override
  Future<void> hardDeleteRecipe(String recipeId) async {
    try {
      final data = await _remote.getRecipeById(
        recipeId: recipeId,
        groupId: _groupId,
      );
      if (data != null) {
        final recipe = RecipeModel.fromSupabaseWithRelations(data);
        if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
          await _storage.deleteImage(recipe.imageUrl!);
        }
      }

      await _remote.deleteRecipeCategories(recipeId);
      await _remote.deleteRecipeIngredients(recipeId);
      await _remote.deleteTimersForRecipe(recipeId);
      await _remote.hardDeleteRecipe(recipeId);
      await _dao.deleteRecipe(recipeId);
    } catch (e) {
      throw RecipeDeletionException(e.toString());
    }
  }
}
