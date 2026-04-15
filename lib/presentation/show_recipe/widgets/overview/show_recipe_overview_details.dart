import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/common/display_ingredient.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/overview/add_to_shopping_list_sheet.dart';
import 'package:meal_planner/services/providers/recipe/linked_recipe_provider.dart';

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
                    currentPortions: currentPortions,
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...scaledSections.map((section) {
            if (section.isLinked) {
              return _LinkedSectionWidget(
                section: section,
                currentPortions: currentPortions,
              );
            }
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
                          const Divider(),
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

class _LinkedSectionWidget extends ConsumerWidget {
  final IngredientSection section;
  final int currentPortions;

  const _LinkedSectionWidget({
    required this.section,
    required this.currentPortions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final asyncRecipe = ref.watch(linkedRecipeProvider(section.linkedRecipeId!));

    final displayName = asyncRecipe.asData?.value?.name ?? section.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.router.root
              .push(ShowRecipeRoute(recipeId: section.linkedRecipeId!)),
          child: Row(
            children: [
              Icon(Icons.link, size: 18, color: colorScheme.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  displayName,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.open_in_new, size: 14, color: colorScheme.primary),
            ],
          ),
        ),
        const SizedBox(height: 8),
        asyncRecipe.when(
          data: (linkedRecipe) {
            if (linkedRecipe == null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Rezept nicht mehr verfügbar',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }
            final scaleFactor = currentPortions / linkedRecipe.portions;
            final ingredients = linkedRecipe.ingredientSections
                .expand((s) => s.ingredients)
                .map((ing) => ing.scale(scaleFactor))
                .toList();
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    DisplayIngredient(ingredient: ingredients[index]),
                    if (index != ingredients.length - 1)
                      const Divider(),
                  ],
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Fehler beim Laden des Rezepts',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
