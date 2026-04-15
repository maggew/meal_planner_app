import 'package:meal_planner/data/model/ingredient_model.dart';
import 'package:meal_planner/data/model/recipe_model.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RecipeRemoteDatasource {
  Future<PostgrestMap?> getRecipeById({
    required String recipeId,
    required String groupId,
  });

  Future<List<String>> getAllCategories({required String groupId});

  Future<List<Map<String, dynamic>>> getRecipesByCategoryId({
    required String categoryId,
    required String groupId,
    required bool isDeleted,
    required RecipeSortOption sortOption,
  });

  Future<List<Map<String, dynamic>>> getRecipesByCategories({
    required List<String> categories,
    required String groupId,
  });

  Future<List<Map<String, dynamic>>> getDeletedRecipes({
    required String groupId,
    required int offset,
    required int limit,
  });

  Future<void> restoreRecipe(String recipeId);
  Future<void> hardDeleteRecipe(String recipeId);
  Future<void> softDeleteRecipe(String recipeId);

  Future<void> deleteRecipeCategories(String recipeId);
  Future<void> deleteRecipeIngredients(String recipeId);

  Future<void> updateRecipe(
    String recipeId,
    Map<String, dynamic> data,
  );

  Future<void> insertRecipe({
    required String recipeId,
    required RecipeModel model,
    required String groupId,
    required String createdBy,
    String? imageUrl,
  });

  Future<void> saveRecipeCategories({
    required String recipeId,
    required List<String> categories,
    required String groupId,
  });

  Future<String> upsertCategory({
    required String name,
    required String groupId,
  });

  Future<void> saveRecipeIngredients({
    required String recipeId,
    required List<IngredientModel> ingredients,
  });

  Future<String> upsertIngredient({required String name});

  Future<String?> getRecipeTitle({
    required String recipeId,
    required String groupId,
  });

  Future<List<Map<String, dynamic>>> getRecipeManifest({
    required String groupId,
  });

  Future<List<Map<String, dynamic>>> getRecipesByIds({
    required List<String> ids,
    required String groupId,
  });

  Future<void> incrementTimesCooked({
    required String recipeId,
  });

  // Timer
  Future<List<Map<String, dynamic>>> getTimersForRecipe(String recipeId);
  Future<Map<String, dynamic>> upsertTimer(Map<String, dynamic> data);
  Future<void> deleteTimer(String recipeId, int stepIndex);
  Future<void> deleteTimersForRecipe(String recipeId);
}
