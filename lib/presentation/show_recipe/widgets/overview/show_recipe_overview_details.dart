import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/common/display_ingredient.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_provider.dart';

class ShowRecipeOverviewDetails extends ConsumerWidget {
  final Recipe recipe;
  const ShowRecipeOverviewDetails({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      padding: EdgeInsets.all(10),
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
              // Portions
              Text(
                "Portionen: ${recipe.portions.toString()}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                  onPressed: () => _showAddToShoppingListSheet(
                      context, ref, recipe.ingredientSections),
                  icon: Icon(Icons.add_shopping_cart)),
            ],
          ),
          SizedBox(height: 10),
          // Sections + Ingredients
          ...recipe.ingredientSections.map((section) {
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

void _showAddToShoppingListSheet(
  BuildContext context,
  WidgetRef ref,
  List<IngredientSection> sections,
) {
  final selectedSections = <int>{};
  // Wenn nur eine Sektion, direkt alle auswählen
  if (sections.length == 1) {
    selectedSections.add(0);
  }

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Zur Einkaufsliste hinzufügen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...sections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final section = entry.value;
                  return CheckboxListTile(
                    title: Text(section.title),
                    subtitle: Text(
                      '${section.ingredients.length} Zutaten',
                    ),
                    value: selectedSections.contains(index),
                    onChanged: (checked) {
                      setSheetState(() {
                        if (checked == true) {
                          selectedSections.add(index);
                        } else {
                          selectedSections.remove(index);
                        }
                      });
                    },
                  );
                }),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedSections.isEmpty
                        ? null
                        : () {
                            final ingredients = selectedSections
                                .expand((i) => sections[i].ingredients)
                                .toList();
                            ref
                                .read(shoppingListActionsProvider.notifier)
                                .addItemsFromIngredients(ingredients);
                            context.router.pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${ingredients.length} Zutaten zur Einkaufsliste hinzugefügt',
                                ),
                              ),
                            );
                          },
                    child: Text(
                      'Hinzufügen (${selectedSections.length} Sektionen)',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
