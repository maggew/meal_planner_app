import 'package:cool_dropdown/controllers/dropdown_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/add_recipe/widgets/add_recipe_button.dart';
import 'package:meal_planner/presentation/add_recipe/widgets/add_recipe_category_selection.dart';
import 'package:meal_planner/presentation/add_recipe/widgets/add_recipe_ingredients.dart';
import 'package:meal_planner/presentation/add_recipe/widgets/add_recipe_instructions.dart';
import 'package:meal_planner/presentation/add_recipe/widgets/add_recipe_picture.dart';
import 'package:meal_planner/presentation/add_recipe/widgets/add_recipe_portion_selection.dart';
import 'package:meal_planner/presentation/add_recipe/widgets/add_recipe_recipe_name_textformfield.dart';

class AddRecipeBody extends ConsumerStatefulWidget {
  const AddRecipeBody({super.key});

  @override
  ConsumerState<AddRecipeBody> createState() => _AddRecipeBodyState();
}

class _AddRecipeBodyState extends ConsumerState<AddRecipeBody> {
  late final TextEditingController _recipeNameController;
  late final TextEditingController _recipeInstructionsController;
  late final DropdownController _categoryDropdownController;
  late final DropdownController _portionDropdownController;

  @override
  void initState() {
    super.initState();
    _recipeNameController = TextEditingController();
    _recipeInstructionsController = TextEditingController();
    _categoryDropdownController = DropdownController();
    _portionDropdownController = DropdownController();
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
          AddRecipeRecipeNameTextformfield(
              recipeNameController: _recipeNameController),
          AddRecipeCategorySelection(
            categoryDropdownController: _categoryDropdownController,
          ),
          SizedBox(height: 30),
          AddRecipePortionSelection(
            portionDropdownController: _portionDropdownController,
          ),
          SizedBox(height: 30),
          AddRecipeIngredients(),
          SizedBox(height: 30),
          AddRecipeInstructions(
            recipeInstructionsController: _recipeInstructionsController,
          ),
          SizedBox(height: 30),
          AddRecipePicture(),
          SizedBox(height: 50),
          AddRecipeButton(
              recipeNameController: _recipeNameController,
              recipeInstructionsController: _recipeInstructionsController),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
