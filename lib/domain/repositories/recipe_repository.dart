import 'dart:io';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';

abstract class RecipeRepository {
  Future<String> saveRecipe(Recipe recipe, File? image, String createdBy);

  Future<List<Recipe>> getRecipesByCategory({
    required String category,
    required int offset,
    required int limit,
    required RecipeSortOption sortOption,
    required bool isDeleted,
  });

  Future<List<Recipe>> getRecipesByCategories(List<String> categories);

  Future<Recipe?> getRecipeById(String recipeId);

  Future<void> updateRecipe(Recipe recipe, File? newImage);

  Future<void> deleteRecipe(String recipeId);
  Future<void> restoreRecipe(String recipeId);
  Future<void> hardDeleteRecipe(String recipeId);

  Future<List<String>> getAllCategories();

  // Timer logic
  Future<List<RecipeTimer>> getTimersForRecipe(String recipeId);
  Future<RecipeTimer> upsertTimer(RecipeTimer timer);
  Future<void> deleteTimer(String recipeId, int stepIndex);
}
