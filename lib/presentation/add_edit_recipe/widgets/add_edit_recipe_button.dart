import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/services/carb_tag_detector.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/groups/group_category_provider.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/recipe/add_edit_recipe_ingredients_provider.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';
import 'package:meal_planner/services/providers/recipe/carb_tag_selection_provider.dart';
import 'package:meal_planner/services/providers/recipe/cookbook_initial_category_provider.dart';
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
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(recipeUploadProvider);

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        uploadState.when(
          data: (_) => ElevatedButton(
            onPressed: () => _handleUpload(context, ref, existingRecipe),
            child: Text(
              isEditMode ? "Rezept aktualisieren" : "Speichern",
            ),
          ),
          error: (error, _) => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
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
    // Provider speichert IDs → in Namen für Recipe-Entity und Cache-Invalidierung umwandeln
    final selectedCategoryIds = ref.read(selectedCategoriesProvider);
    final allGroupCategories = await ref.read(groupCategoriesProvider.future);
    final selectedCategories = allGroupCategories
        .where((c) => selectedCategoryIds.contains(c.id))
        .map((c) => c.name)
        .toList();

    final selectedPortions = ref.read(selectedPortionsProvider);
    final ingredientState = ref.read(ingredientsProvider);

    final image = ref.read(imageManagerProvider).photo;

    final validation = ref.validateRecipe(
      name: recipeNameController.text,
      instructions: recipeInstructionsController.text,
      sections: ingredientState.sections,
      categories: selectedCategories,
    );

    if (!validation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validation.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final ingredientSections = ingredientState.sections.map((section) {
      final rawTitle = section.titleController.text.trim();

      return IngredientSection(
        title: rawTitle.isEmpty ? 'Zutaten' : rawTitle,
        ingredients: section.items.map((item) {
          return item.ingredient.copyWith(
            name: item.nameController.text.trim(),
            amount: item.amountController.text.trim(),
            unit: item.unit,
          );
        }).toList(),
      );
    }).toList();

    // CarbTags: use manually selected ones, auto-detect if empty
    var selectedCarbTags = ref.read(carbTagSelectionProvider);
    if (selectedCarbTags.isEmpty) {
      selectedCarbTags = CarbTagDetector.detect(ingredientSections)
          .map((t) => t.value)
          .toList();
    }

    Recipe recipe = Recipe(
      id: existingRecipe?.id,
      name: recipeNameController.text,
      categories: selectedCategories,
      portions: selectedPortions,
      ingredientSections: ingredientSections,
      instructions: recipeInstructionsController.text,
      imageUrl: existingRecipe?.imageUrl,
      carbTags: selectedCarbTags,
    );

    final recipeRepo = ref.read(recipeUploadProvider.notifier);
    if (existingRecipe != null) {
      await recipeRepo.updateRecipe(recipe, image);
    } else {
      await recipeRepo.createRecipe(recipe, image);
    }

    final oldCategoryIds = allGroupCategories
        .where((c) => (existingRecipe?.categories ?? []).contains(c.name))
        .map((c) => c.id);

    for (final id in {...selectedCategoryIds, ...oldCategoryIds}) {
      ref.invalidate(recipesPaginationProvider(id));
    }

    // Kochbuch zur ersten Kategorie des Rezepts navigieren
    if (existingRecipe == null && selectedCategoryIds.isNotEmpty) {
      ref
          .read(cookbookInitialCategoryProvider.notifier)
          .set(selectedCategoryIds.first);
    }

    _resetForm(
      recipeNameController: recipeNameController,
      recipeInstructionsController: recipeInstructionsController,
      ref: ref,
    );

    if (context.mounted) {
      context.router.replace(const CookbookRoute());
    }
  }

  void _resetForm({
    required WidgetRef ref,
    required TextEditingController recipeNameController,
    required TextEditingController recipeInstructionsController,
  }) {
    ref.read(selectedCategoriesProvider.notifier).clear();
    ref.read(selectedPortionsProvider.notifier).set(defaultPortions);
    ref.read(imageManagerProvider.notifier).clearPhoto();
    ref.read(carbTagSelectionProvider.notifier).clear();
    recipeNameController.clear();
    recipeInstructionsController.clear();
  }
}
