import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';

class ShowRecipeOverviewInstructions extends StatelessWidget {
  final Recipe recipe;
  const ShowRecipeOverviewInstructions({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final ColorScheme _colorScheme = Theme.of(context).colorScheme;
    final TextTheme _textTheme = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: _colorScheme.surfaceContainer,
      ),
      child: Container(
        margin: EdgeInsets.all(10),
        child: Text(recipe.instructions, style: _textTheme.bodyMedium),
      ),
    );
  }
}
