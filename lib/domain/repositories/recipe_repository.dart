import 'dart:io';
import 'package:meal_planner/domain/entities/recipe.dart';

abstract class RecipeRepository {
  Future<String> saveRecipe(Recipe recipe, File? image);

  Future<String> uploadRecipeImage(File imageFile);

  Future<List<Recipe>> getRecipesByCategory(String category);

  Future<Recipe?> getRecipeById(String recipeId, String category);

  Future<void> updateRecipe(String recipeId, String category, Recipe recipe);

  Future<void> deleteRecipe(String recipeId, String category);

  Future<void> deleteRecipeImage(String imageUrl);
}
