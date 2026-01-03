import 'dart:core';

import 'package:auto_route/auto_route.dart';
import 'package:cool_dropdown/controllers/dropdown_controller.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_body.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';

@RoutePage()
class AddRecipeFromKeyboardPage extends StatelessWidget {
  final DropdownController _categoryDropdownController = DropdownController();
  final DropdownController _portionDropdownController = DropdownController();

  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _recipeInstructionsController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(
        title: "Neues Rezept erstellen",
        hasActionButton: false,
      ),
      scaffoldBody: AddRecipeBody(
        categoryDropdownController: _categoryDropdownController,
        recipeNameController: _recipeNameController,
        recipeInstructionsController: _recipeInstructionsController,
        portionDropdownController: _portionDropdownController,
      ),
    );
  }
}
