import 'package:cool_dropdown/controllers/dropdown_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_button.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_category_selection.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_ingredients.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_instructions.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_picture.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_portion_selection.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_recipe_name_textformfield.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/restructuring_of_ingredient_input/add_edit_recipe_ingredients_alt.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

class AddEditRecipeBody extends ConsumerStatefulWidget {
  final Recipe? existingRecipe;
  const AddEditRecipeBody({super.key, required this.existingRecipe});

  bool get isEditMode => existingRecipe != null;

  @override
  ConsumerState<AddEditRecipeBody> createState() => _AddEditRecipeBodyState();
}

class _AddEditRecipeBodyState extends ConsumerState<AddEditRecipeBody> {
  late final TextEditingController _recipeNameController;
  late final TextEditingController _recipeInstructionsController;
  late final DropdownController _categoryDropdownController;
  late final DropdownController _portionDropdownController;

  @override
  void initState() {
    super.initState();

    final recipe = widget.existingRecipe;

    _recipeNameController = TextEditingController(text: recipe?.name ?? "");
    _recipeInstructionsController =
        TextEditingController(text: recipe?.instructions ?? "");
    _categoryDropdownController = DropdownController();
    _portionDropdownController = DropdownController();

    // Immer erst clearen, dann ggf. befüllen
    Future.microtask(() {
      // Reset
      ref.read(selectedCategoryProvider.notifier).state = DEFAULT_CATEGORY;
      ref.read(selectedPortionsProvider.notifier).state = DEFAULT_PORTIONS;

      // Edit-Modus: befüllen
      if (recipe != null) {
        ref.read(selectedCategoryProvider.notifier).state = recipe.category;
        ref.read(selectedPortionsProvider.notifier).state = recipe.portions;
      }
    });
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _recipeInstructionsController.dispose();
    _categoryDropdownController.dispose();
    _portionDropdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AddEditRecipeRecipeNameTextformfield(
              recipeNameController: _recipeNameController),
          AddEditRecipeCategorySelection(
            categoryDropdownController: _categoryDropdownController,
            initialCategory: widget.existingRecipe?.category,
          ),
          SizedBox(height: 30),
          AddEditRecipePortionSelection(
            portionDropdownController: _portionDropdownController,
            initialPortions: widget.existingRecipe?.portions,
          ),
          SizedBox(height: 30),
          AddEditRecipeIngredientsAlt(
            key: ValueKey(widget.existingRecipe?.id),
            initialIngredients: widget.existingRecipe?.ingredients,
          ),
          // AddEditRecipeIngredients(
          //   key: ValueKey(widget.existingRecipe?.id),
          //   initialIngredients: widget.existingRecipe?.ingredients,
          // ),
          SizedBox(height: 30),
          AddEditRecipeInstructions(
            recipeInstructionsController: _recipeInstructionsController,
          ),
          SizedBox(height: 30),
          AddEditRecipePicture(
            existingImageUrl: widget.existingRecipe?.imageUrl,
          ),
          SizedBox(height: 50),
          AddEditRecipeButton(
            recipeNameController: _recipeNameController,
            recipeInstructionsController: _recipeInstructionsController,
            existingRecipe: widget.existingRecipe,
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
