import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_button.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_category_selection.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_ingredients_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_instructions.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_picture.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_portion_selection.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_recipe_name_textformfield.dart';
import 'package:meal_planner/services/providers/recipe/add_edit_recipe_ingredients_provider.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

class AddEditRecipeBody extends ConsumerStatefulWidget {
  // Wieder Consumer
  final Recipe? existingRecipe;
  const AddEditRecipeBody({super.key, required this.existingRecipe});

  @override
  ConsumerState<AddEditRecipeBody> createState() => _AddEditRecipeBodyState();
}

class _AddEditRecipeBodyState extends ConsumerState<AddEditRecipeBody> {
  late final TextEditingController _recipeNameController;
  late final TextEditingController _recipeInstructionsController;
  AddEditRecipeIngredientsProvider? ingredientsProvider;

  int _loadStage = 0; // Stufenweises Laden

  @override
  void initState() {
    super.initState();
    final recipe = widget.existingRecipe;

    _recipeNameController = TextEditingController(text: recipe?.name ?? "");
    _recipeInstructionsController =
        TextEditingController(text: recipe?.instructions ?? "");
    // Stufenweise laden über mehrere Frames
    _loadNextStage();
  }

  void _loadNextStage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_loadStage == 0) {
        ingredientsProvider = addEditRecipeIngredientsProvider(
            widget.existingRecipe?.ingredients);
        ref
            .read(selectedCategoriesProvider.notifier)
            .set(widget.existingRecipe?.categories ?? []);
        ref
            .read(selectedPortionsProvider.notifier)
            .set(widget.existingRecipe?.portions ?? DEFAULT_PORTIONS);
      }

      setState(() {
        _loadStage++;
      });

      if (_loadStage < 5) {
        _loadNextStage();
      } else {}
    });
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
          if (_loadStage >= 1) ...[
            AddEditRecipeCategorySelection(
              initialCategories: widget.existingRecipe?.categories,
            ),
            SizedBox(height: 30),
          ],
          if (_loadStage >= 2) ...[
            AddEditRecipePortionSelection(
              initialPortions: widget.existingRecipe?.portions,
            ),
            SizedBox(height: 30),
          ],
          if (_loadStage >= 3 && ingredientsProvider != null) ...[
            AddEditRecipeIngredientsItem(
              key: ValueKey(widget.existingRecipe?.id),
              ingredientsProvider: ingredientsProvider!,
            ),
            SizedBox(height: 30),
          ],
          if (_loadStage >= 4) ...[
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
              ingredientsProvider: ingredientsProvider!,
              isEditMode: widget.existingRecipe != null,
            ),
          ],
          // Immer einen Platzhalter zeigen wenn noch am Laden
          if (_loadStage < 4)
            SizedBox(
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            ),
          SizedBox(height: 100),
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
