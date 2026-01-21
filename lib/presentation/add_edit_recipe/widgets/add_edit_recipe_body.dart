import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_add_section_button.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_button.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_category_selection.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_ingredient_section_widget.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_ingredients_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_ingredients_section_block.dart';
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

  @override
  void initState() {
    super.initState();
    _recipeNameController =
        TextEditingController(text: widget.existingRecipe?.name ?? '');
    _recipeInstructionsController =
        TextEditingController(text: widget.existingRecipe?.instructions ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final ingredientsProvider = addEditRecipeIngredientsProvider(
      widget.existingRecipe?.ingredientSections,
    );

    final state = ref.watch(ingredientsProvider);
    final sections = state.sections;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          AddEditRecipeCategorySelection(
            initialCategories: widget.existingRecipe?.categories,
          ),

          const SizedBox(height: 30),

          // ------------------------------------------------------------
          // Portionen
          // ------------------------------------------------------------
          AddEditRecipePortionSelection(
            initialPortions: widget.existingRecipe?.portions,
          ),

          const SizedBox(height: 30),

          // ------------------------------------------------------------
          // Zutaten + Sections
          // ------------------------------------------------------------
          // AddEditRecipeIngredientsItem(
          //   ingredientsProvider: ingredientsProvider,
          // ),
          AddEditRecipeIngredientsBlock(
              ingredientsProvider: ingredientsProvider),

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

