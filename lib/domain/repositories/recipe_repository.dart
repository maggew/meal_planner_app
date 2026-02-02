import 'dart:io';
import 'package:meal_planner/domain/entities/recipe.dart';

abstract class RecipeRepository {
  Future<String> saveRecipe(Recipe recipe, File? image);

  Future<List<Recipe>> getRecipesByCategory(String category);

  Future<List<Recipe>> getRecipesByCategories(List<String> categories);

  Future<Recipe?> getRecipeById(String recipeId);

  Future<void> updateRecipe(Recipe recipe, File? newImage);

  Future<void> deleteRecipe(String recipeId);
  Future<void> restoreRecipe(String recipeId);
  Future<void> hardDeleteRecipe(String recipeId);

  Future<List<String>> getAllCategories();
}
