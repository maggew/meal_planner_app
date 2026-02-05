import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_button.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_category_selection.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_ingredients_widget.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_instructions.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_picture.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_portion_selection.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_recipe_name_textformfield.dart';
import 'package:meal_planner/services/providers/recipe/add_edit_recipe_ingredients_provider.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

class AddEditRecipeBody extends ConsumerStatefulWidget {
  final Recipe? existingRecipe;

  const AddEditRecipeBody({
    super.key,
    required this.existingRecipe,
  });

  @override
  ConsumerState<AddEditRecipeBody> createState() => _AddEditRecipeBodyState();
}

class _AddEditRecipeBodyState extends ConsumerState<AddEditRecipeBody> {
  late final TextEditingController _recipeNameController;
  late final TextEditingController _recipeInstructionsController;
  late final AddEditRecipeIngredientsProvider ingredientsProvider;

  @override
  void initState() {
    super.initState();
    _recipeNameController =
        TextEditingController(text: widget.existingRecipe?.name ?? '');
    _recipeInstructionsController =
        TextEditingController(text: widget.existingRecipe?.instructions ?? '');

    ingredientsProvider = addEditRecipeIngredientsProvider(
      widget.existingRecipe?.ingredientSections,
    );
    if (widget.existingRecipe != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // setting initial categories
        ref
            .read(selectedCategoriesProvider.notifier)
            .set(widget.existingRecipe!.categories);
        // setting intial portions
        ref
            .read(selectedPortionsProvider.notifier)
            .set(widget.existingRecipe!.portions);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ------------------------------------------------------------
          // Rezeptname
          // ------------------------------------------------------------
          AddEditRecipeRecipeNameTextformfield(
            recipeNameController: _recipeNameController,
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------------------
          // Kategorien
          // ------------------------------------------------------------
          AddEditRecipeCategorySelection(),

          const SizedBox(height: 30),

          // ------------------------------------------------------------
          // Portionen
          // ------------------------------------------------------------
          AddEditRecipePortionSelection(),

          const SizedBox(height: 30),

          // ------------------------------------------------------------
          // Zutaten + Sections
          // ------------------------------------------------------------
          // AddEditRecipeIngredientsBlock(
          //     ingredientsProvider: ingredientsProvider),
          AddEditRecipeIngredientsWidget(
            ingredientsProvider: ingredientsProvider,
          ),

          const SizedBox(height: 30),

          // ------------------------------------------------------------
          // Anleitung
          // ------------------------------------------------------------
          AddEditRecipeInstructions(
            recipeInstructionsController: _recipeInstructionsController,
          ),

          const SizedBox(height: 30),

          // ------------------------------------------------------------
          // Bild
          // ------------------------------------------------------------
          AddEditRecipePicture(
            existingImageUrl: widget.existingRecipe?.imageUrl,
          ),

          const SizedBox(height: 50),

          // ------------------------------------------------------------
          // Speichern / Aktualisieren
          // ------------------------------------------------------------
          AddEditRecipeButton(
            recipeNameController: _recipeNameController,
            recipeInstructionsController: _recipeInstructionsController,
            existingRecipe: widget.existingRecipe,
            ingredientsProvider: ingredientsProvider,
            isEditMode: widget.existingRecipe != null,
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _recipeInstructionsController.dispose();
    super.dispose();
  }
}
