import 'dart:io';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';

abstract class RecipeRepository {
  Future<String> saveRecipe(Recipe recipe, File? image, String createdBy);

  Future<List<Recipe>> getRecipesByCategoryId({
    required String categoryId,
    required RecipeSortOption sortOption,
    required bool isDeleted,
  });

  Future<List<Recipe>> getRecipesByCategories(List<String> categories);

  Future<Recipe?> getRecipeById(String recipeId);

  Future<void> updateRecipe(Recipe recipe, File? newImage);

  Future<void> deleteRecipe(String recipeId);

  Future<List<String>> getAllCategories();

  /// Returns the recipe title for the given [recipeId], or null if not found.
  Future<String?> getRecipeTitle(String recipeId);

  /// Searches all recipes by name (case-insensitive) from the local cache.
  Future<List<Recipe>> searchRecipes(String query);

  /// Increments the `times_cooked` counter for the given recipe by 1.
  Future<void> incrementTimesCooked(String recipeId);

  // Timer logic
  Future<List<RecipeTimer>> getTimersForRecipe(String recipeId);
  Future<RecipeTimer> upsertTimer(RecipeTimer timer);
  Future<void> deleteTimer(String recipeId, int stepIndex);
}
