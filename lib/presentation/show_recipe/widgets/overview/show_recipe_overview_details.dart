import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/common/display_ingredient.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/overview/add_to_shopping_list_sheet.dart';

class ShowRecipeOverviewDetails extends StatelessWidget {
  final Recipe recipe;
  final List<IngredientSection> scaledSections;
  final int currentPortions;
  final ValueChanged<int> onPortionsChanged;

  const ShowRecipeOverviewDetails({
    super.key,
    required this.recipe,
    required this.scaledSections,
    required this.currentPortions,
    required this.onPortionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: AppDimensions.borderRadiusAll,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Portionen:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.remove),
                    onPressed: currentPortions > 1
                        ? () => onPortionsChanged(currentPortions - 1)
                        : null,
                  ),
                  Text(
                    '$currentPortions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add),
                    onPressed: () => onPortionsChanged(currentPortions + 1),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AddToShoppingListSheet(
                    sections: scaledSections,
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...scaledSections.map((section) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.title),
                const SizedBox(height: 8),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: section.ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = section.ingredients[index];
                    return Column(
                      children: [
                        DisplayIngredient(ingredient: ingredient),
                        if (index != section.ingredients.length - 1)
                          const Divider(thickness: 2),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }
}
