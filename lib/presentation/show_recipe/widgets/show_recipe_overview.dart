import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/common/native_ad_widget.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/overview/show_recipe_overview_details.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/overview/show_recipe_overview_instructions.dart';

class ShowRecipeOverview extends StatefulWidget {
  final Recipe recipe;
  final Widget image;
  final List<IngredientSection> scaledSections;
  final int currentPortions;
  final ValueChanged<int> onPortionsChanged;

  const ShowRecipeOverview({
    super.key,
    required this.recipe,
    required this.image,
    required this.scaledSections,
    required this.currentPortions,
    required this.onPortionsChanged,
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
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: Hero(
              tag: widget.recipe.id ?? widget.recipe.name,
              child: ClipRRect(
                borderRadius: AppDimensions.borderRadiusAll,
                child: widget.image,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const NativeAdWidget(),
          const SizedBox(height: 8),
          ShowRecipeOverviewDetails(
            recipe: widget.recipe,
            scaledSections: widget.scaledSections,
            currentPortions: widget.currentPortions,
            onPortionsChanged: widget.onPortionsChanged,
          ),
          ShowRecipeOverviewInstructions(recipe: widget.recipe),
        ],
      ),
    );
  }
}
