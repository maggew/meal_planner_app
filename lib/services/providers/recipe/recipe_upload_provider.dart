import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

part 'recipe_upload_provider.g.dart';

@riverpod
class RecipeUpload extends _$RecipeUpload {
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> createRecipe(Recipe recipe, File? image) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final recipeRepo = ref.read(recipeRepositoryProvider);
      await recipeRepo.saveRecipe(recipe, image);
    });
  }

  Future<void> updateRecipe(Recipe recipe, File? image) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final recipeRepo = ref.read(recipeRepositoryProvider);
      await recipeRepo.updateRecipe(recipe, image);
    });
  }
}
