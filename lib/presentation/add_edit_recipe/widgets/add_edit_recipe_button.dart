import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/recipe/add_edit_recipe_ingredients_provider.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_pagination_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_upload_provider.dart';

class AddEditRecipeButton extends ConsumerWidget {
  final TextEditingController recipeNameController;
  final TextEditingController recipeInstructionsController;
  final bool isEditMode;
  final Recipe? existingRecipe;
  final AddEditRecipeIngredientsProvider ingredientsProvider;
  const AddEditRecipeButton({
    super.key,
    required this.recipeNameController,
    required this.recipeInstructionsController,
    required this.ingredientsProvider,
    required this.isEditMode,
    required this.existingRecipe,
  });

  @override
  build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(recipeUploadProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        uploadState.when(
          data: (_) => ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(100, 40),
            ),
            onPressed: () => _handleUpload(context, ref, existingRecipe),
            child: Text(
              isEditMode ? "Rezpet updaten" : "Speichern",
            ),
          ),
          error: (error, _) => ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(100, 40),
              backgroundColor: Colors.red,
            ),
            onPressed: () => _handleUpload(context, ref, existingRecipe),
            child: const Text("Erneut versuchen"),
          ),
          loading: () => const SizedBox(
            height: 40,
            width: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleUpload(
      BuildContext context, WidgetRef ref, Recipe? existingRecipe) async {
    final selectedCategories = ref.read(selectedCategoriesProvider);
    final selectedPortions = ref.read(selectedPortionsProvider);
    final ingredients =
        ref.read(ingredientsProvider.notifier).buildIngredientsForSave();
    final image = ref.read(imageManagerProvider).recipePhoto;

    final validation = ref.validateRecipe(
      name: recipeNameController.text,
      instructions: recipeInstructionsController.text,
      ingredients: ingredients,
    );

    if (!validation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validation.error!),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      Recipe recipe = Recipe(
        id: existingRecipe?.id,
        name: recipeNameController.text,
        //TODO: muss angepasst werden, wenn mehrere kategorien unterstützt werden
        // categories: selectedCategories --> ist eine List<String>
        categories: selectedCategories,
        portions: selectedPortions,
        ingredients: ingredients,
        instructions: recipeInstructionsController.text,
        imageUrl: existingRecipe?.imageUrl,
      );

      final recipeRepo = ref.read(recipeUploadProvider.notifier);
      if (existingRecipe != null) {
        print("trying to update recipe with id: ${recipe.id}");
        await recipeRepo.updateRecipe(recipe, image);
      } else {
        await recipeRepo.createRecipe(recipe, image);
      }

      for (final category in recipe.categories) {
        print("now invalidating... for category: $category");
        ref.invalidate(recipesPaginationProvider(category.toLowerCase()));
      }

      _resetForm(
        recipeNameController: recipeNameController,
        recipeInstructionsController: recipeInstructionsController,
        ref: ref,
      );

      context.router.replace(const CookbookRoute());
    }
  }

  void _resetForm({
    required WidgetRef ref,
    required TextEditingController recipeNameController,
    required TextEditingController recipeInstructionsController,
  }) {
    //ref.read(ingredientsProvider.notifier).clear();
    ref.read(selectedCategoriesProvider.notifier).set([DEFAULT_CATEGORY]);
    ref.read(selectedPortionsProvider.notifier).set(DEFAULT_PORTIONS);
    ref.read(imageManagerProvider.notifier).clearRecipePhoto();
    recipeNameController.clear();
    recipeInstructionsController.clear();
  }
}
