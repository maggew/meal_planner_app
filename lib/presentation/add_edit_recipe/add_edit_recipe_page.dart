import 'dart:core';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_body.dart';
import 'package:meal_planner/presentation/common/app_background.dart';

@RoutePage()
class AddEditRecipePage extends ConsumerWidget {
  final Recipe? existingRecipe;

  const AddEditRecipePage({super.key, this.existingRecipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isEditMode = existingRecipe != null;
    return AppBackground(
      scaffoldAppBar: AppBar(
        leading: IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.transparent),
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: Colors.black,
            ),
            onPressed: () {
              context.router.pop();
            }),
        title: Text(
          isEditMode ? "Rezept bearbeiten" : "Neues Rezept erstellen",
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      scaffoldBody: AddEditRecipeBody(existingRecipe: existingRecipe),
    );
  }
}
