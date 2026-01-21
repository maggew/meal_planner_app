import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/overview/show_recipe_overview_details.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/overview/show_recipe_overview_instructions.dart';

class ShowRecipeOverview extends StatefulWidget {
  final Recipe recipe;
  final Image image;

  const ShowRecipeOverview({
    super.key,
    required this.recipe,
    required this.image,
  });

  @override
  State<ShowRecipeOverview> createState() => _ShowRecipeOverviewState();
}

class _ShowRecipeOverviewState extends State<ShowRecipeOverview>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Hero(
            tag: widget.recipe.name,
            child: widget.image,
          ),
          ShowRecipeOverviewDetails(recipe: widget.recipe),
          ShowRecipeOverviewInstructions(recipe: widget.recipe),
        ],
      ),
    );
  }
}
