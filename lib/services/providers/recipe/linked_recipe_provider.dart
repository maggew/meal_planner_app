import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'linked_recipe_provider.g.dart';

@riverpod
Future<Recipe?> linkedRecipe(Ref ref, String recipeId) async {
  ref.keepAlive();
  final repo = ref.read(recipeRepositoryProvider);
  return repo.getRecipeById(recipeId);
}
