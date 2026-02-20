import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/recipe.dart';

class ShowRecipeOverviewInstructions extends StatelessWidget {
  final Recipe recipe;
  const ShowRecipeOverviewInstructions({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final instructions = recipe.instructions.trim();

    if (instructions.isEmpty) return const SizedBox.shrink();

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: AppDimensions.borderRadiusAll,
      ),
      child: Text(recipe.instructions, style: textTheme.bodyMedium),
    );
  }
}
