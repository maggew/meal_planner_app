import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_body.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';

@RoutePage()
class AddEditRecipePage extends StatelessWidget {
  final Recipe? existingRecipe;

  const AddEditRecipePage({super.key, this.existingRecipe});

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = existingRecipe != null;
    return AppBackground(
      applyScreenPadding: true,
      scaffoldAppBar: CommonAppbar(
        leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
            ),
            onPressed: () {
              context.router.pop();
            }),
        title: isEditMode ? "Rezept bearbeiten" : "Neues Rezept erstellen",
      ),
      scaffoldBody: AddEditRecipeBody(existingRecipe: existingRecipe),
    );
  }
}
