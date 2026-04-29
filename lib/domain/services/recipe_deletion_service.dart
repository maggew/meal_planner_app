import 'package:meal_planner/domain/repositories/meal_plan_repository.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';

/// Orchestrates the cross-domain cascade when a recipe is permanently deleted:
///   1. Resolve the recipe name (needed to preserve it as free-text in meal plan).
///   2. Detach all local meal-plan entries referencing this recipe.
///   3. Delete the recipe from the remote store and evict the local cache.
///
/// Keeping this logic here — rather than inside RecipeRepository — makes the
/// cross-domain dependency explicit and visible at the service level.
class RecipeDeletionService {
  const RecipeDeletionService({
    required RecipeRepository recipeRepository,
    required MealPlanRepository mealPlanRepository,
  })  : _recipeRepository = recipeRepository,
        _mealPlanRepository = mealPlanRepository;

  final RecipeRepository _recipeRepository;
  final MealPlanRepository _mealPlanRepository;

  Future<void> deleteRecipe(String recipeId) async {
    final recipe = await _recipeRepository.getRecipeById(recipeId);
    await _mealPlanRepository.detachEntriesByRecipe(recipeId, recipe?.name ?? '');
    await _recipeRepository.deleteRecipe(recipeId);
  }
}
