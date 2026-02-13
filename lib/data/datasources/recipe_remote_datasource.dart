import 'package:meal_planner/data/model/ingredient_model.dart';
import 'package:meal_planner/data/model/recipe_model.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RecipeRemoteDatasource {
  Future<PostgrestMap?> getRecipeById({
    required String recipeId,
    required String groupId,
  });

  Future<List<String>> getAllCategories();

  Future<List<Map<String, dynamic>>> getRecipesByCategory({
    required String category,
    required String groupId,
    required bool isDeleted,
    required int limit,
    required int offset,
    required RecipeSortOption sortOption,
  });

  Future<List<Map<String, dynamic>>> getRecipesByCategories({
    required List<String> categories,
    required String groupId,
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
  });

  Future<String> upsertCategory({required String name});

  Future<void> saveRecipeIngredients({
    required String recipeId,
    required List<IngredientModel> ingredients,
  });

  Future<String> upsertIngredient({required String name});
}
