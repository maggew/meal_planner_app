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
  // Track selected ingredients by section index + ingredient index
  final selected = <int, Set<int>>{};
  for (int s = 0; s < sections.length; s++) {
    selected[s] = <int>{};
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final totalSelected =
              selected.values.fold<int>(0, (sum, s) => sum + s.length);

          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.85,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Zur Einkaufsliste hinzufügen',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: sections.length,
                        itemBuilder: (context, sectionIndex) {
                          final section = sections[sectionIndex];
                          final sectionSelected =
                              selected[sectionIndex] ?? <int>{};
                          final allSelected = sectionSelected.length ==
                              section.ingredients.length;
                          final noneSelected = sectionSelected.isEmpty;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section header — tap to toggle all
                              InkWell(
                                onTap: () {
                                  setSheetState(() {
                                    if (allSelected) {
                                      selected[sectionIndex] = {};
                                    } else {
                                      selected[sectionIndex] = Set<int>.from(
                                        List.generate(
                                            section.ingredients.length,
                                            (i) => i),
                                      );
                                    }
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: allSelected
                                            ? true
                                            : noneSelected
                                                ? false
                                                : null,
                                        tristate: true,
                                        onChanged: (_) {
                                          setSheetState(() {
                                            if (allSelected) {
                                              selected[sectionIndex] = {};
                                            } else {
                                              selected[sectionIndex] =
                                                  Set<int>.from(
                                                List.generate(
                                                    section.ingredients.length,
                                                    (i) => i),
                                              );
                                            }
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: Text(
                                          section.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Individual ingredients
                              ...section.ingredients
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final ingredientIndex = entry.key;
                                final ingredient = entry.value;
                                final isSelected = sectionSelected
                                    .contains(ingredientIndex);

                                return InkWell(
                                  onTap: () {
                                    setSheetState(() {
                                      if (isSelected) {
                                        selected[sectionIndex]!
                                            .remove(ingredientIndex);
                                      } else {
                                        selected[sectionIndex]!
                                            .add(ingredientIndex);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 32),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: isSelected,
                                          onChanged: (checked) {
                                            setSheetState(() {
                                              if (checked == true) {
                                                selected[sectionIndex]!
                                                    .add(ingredientIndex);
                                              } else {
                                                selected[sectionIndex]!
                                                    .remove(ingredientIndex);
                                              }
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          width: 65,
                                          child: Text(
                                            '${ingredient.amount ?? ''} ${ingredient.unit?.displayName ?? ''}'
                                                .trim(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(ingredient.name),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              if (sectionIndex < sections.length - 1)
                                const Divider(height: 16),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: totalSelected == 0
                            ? null
                            : () {
                                final ingredients = <Ingredient>[];
                                for (final entry in selected.entries) {
                                  for (final i in entry.value) {
                                    ingredients
                                        .add(sections[entry.key].ingredients[i]);
                                  }
                                }
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
                          'Hinzufügen ($totalSelected Zutaten)',
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
    },
  );
}
