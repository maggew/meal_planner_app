import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/overview/show_recipe_overview_details.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/overview/show_recipe_overview_instructions.dart';

class ShowRecipeOverview extends StatelessWidget {
  final Recipe recipe;
  final Image image;
  const ShowRecipeOverview({
    super.key,
    required this.recipe,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Hero(
            tag: recipe.name,
            child: image,
          ),
          ShowRecipeOverviewDetails(recipe: recipe),
          ShowRecipeOverviewInstructions(recipe: recipe),
        ],
      ),
    );
  }
}
