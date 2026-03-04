import 'package:meal_planner/domain/entities/recipe.dart';

abstract class TrashRepository {
  Future<List<Recipe>> getDeletedRecipes({
    required int offset,
    required int limit,
  });

  Future<void> restoreRecipe(String recipeId);
  Future<void> hardDeleteRecipe(String recipeId);
}
