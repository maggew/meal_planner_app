import 'dart:io';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
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
      final userId = ref.read(sessionProvider).userId!;

      // Bild wurde ggf. schon beim Auswählen hochgeladen — dann URL nehmen
      // und kein erneutes Hochladen in saveRecipe auslösen.
      Recipe recipeToSave = recipe;
      File? imageToUpload = image;
      if (image != null) {
        final pending = ref.read(imageManagerProvider).pendingPhotoUpload;
        if (pending != null) {
          final preUploadedUrl = await pending;
          if (preUploadedUrl != null) {
            recipeToSave = recipe.copyWith(imageUrl: preUploadedUrl);
            imageToUpload = null;
          }
        }
      }

      await recipeRepo.saveRecipe(recipeToSave, imageToUpload, userId);
    });
  }

  Future<void> updateRecipe(Recipe recipe, File? image,
      {String? oldImageUrlToDelete}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final recipeRepo = ref.read(recipeRepositoryProvider);

      // Altes Bild aus Storage löschen, wenn es explizit entfernt wurde
      if (oldImageUrlToDelete != null) {
        await ref
            .read(storageRepositoryProvider)
            .deleteImage(oldImageUrlToDelete);
      }

      // Bild wurde ggf. schon beim Auswählen hochgeladen — dann URL nehmen
      // und kein erneutes Hochladen auslösen. Altes Bild manuell löschen,
      // da das Repo das sonst nur beim eigenen Upload-Pfad tut.
      Recipe recipeToSave = recipe;
      File? imageToUpload = image;
      if (image != null) {
        final pending = ref.read(imageManagerProvider).pendingPhotoUpload;
        if (pending != null) {
          final preUploadedUrl = await pending;
          if (preUploadedUrl != null) {
            if (recipe.imageUrl != null) {
              await ref
                  .read(storageRepositoryProvider)
                  .deleteImage(recipe.imageUrl!);
            }
            recipeToSave = recipe.copyWith(imageUrl: preUploadedUrl);
            imageToUpload = null;
          }
        }
      }

      await recipeRepo.updateRecipe(recipeToSave, imageToUpload);
    });
  }
}
