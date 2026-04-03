import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/presentation/common/extensions/ingredient_inline_text_extenstion.dart';
import 'package:meal_planner/services/providers/recipe/linked_recipe_provider.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_provider.dart';

class AddToShoppingListSheet extends ConsumerStatefulWidget {
  final List<IngredientSection> sections;
  final int currentPortions;

  const AddToShoppingListSheet({
    super.key,
    required this.sections,
    required this.currentPortions,
  });

  @override
  ConsumerState<AddToShoppingListSheet> createState() =>
      _AddToShoppingListSheetState();
}

class _AddToShoppingListSheetState
    extends ConsumerState<AddToShoppingListSheet> {
  late Map<int, Set<int>> _selected;

  List<IngredientSection> _resolveLinkedSections(WidgetRef ref) {
    final resolved = <IngredientSection>[];
    for (final section in widget.sections) {
      if (!section.isLinked) {
        resolved.add(section);
        continue;
      }
      final asyncRecipe =
          ref.watch(linkedRecipeProvider(section.linkedRecipeId!));
      final linkedRecipe = asyncRecipe.asData?.value;
      if (linkedRecipe == null) continue;
      final scaleFactor = widget.currentPortions / linkedRecipe.portions;
      final ingredients = linkedRecipe.ingredientSections
          .expand((s) => s.ingredients)
          .map((ing) => ing.scale(scaleFactor))
          .toList();
      resolved.add(IngredientSection(
        title: linkedRecipe.name,
        ingredients: ingredients,
      ));
    }
    return resolved;
  }

  void _initSelected(List<IngredientSection> sections) {
    _selected = {
      for (int s = 0; s < sections.length; s++) s: <int>{},
    };
  }

  @override
  void initState() {
    super.initState();
    // Initial selection will be rebuilt on first build with resolved sections
    _selected = {};
  }

  @override
  Widget build(BuildContext context) {
    final resolvedSections = _resolveLinkedSections(ref);

    // Re-init selection map when section count changes (e.g. linked recipes load)
    if (_selected.length != resolvedSections.length) {
      _initSelected(resolvedSections);
    }

    final totalSelected =
        _selected.values.fold<int>(0, (sum, s) => sum + s.length);

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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: resolvedSections.length,
                  itemBuilder: (context, sectionIndex) {
                    final section = resolvedSections[sectionIndex];
                    final sectionSelected =
                        _selected[sectionIndex] ?? <int>{};
                    final allSelected =
                        sectionSelected.length == section.ingredients.length;
                    final noneSelected = sectionSelected.isEmpty;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header — tap to toggle all
                        InkWell(
                          onTap: () => setState(() {
                            if (allSelected) {
                              _selected[sectionIndex] = {};
                            } else {
                              _selected[sectionIndex] = Set<int>.from(
                                List.generate(
                                    section.ingredients.length, (i) => i),
                              );
                            }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: allSelected
                                      ? true
                                      : noneSelected
                                          ? false
                                          : null,
                                  tristate: true,
                                  onChanged: (_) => setState(() {
                                    if (allSelected) {
                                      _selected[sectionIndex] = {};
                                    } else {
                                      _selected[sectionIndex] = Set<int>.from(
                                        List.generate(
                                            section.ingredients.length,
                                            (i) => i),
                                      );
                                    }
                                  }),
                                ),
                                Expanded(
                                  child: Text(
                                    section.title,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Individual ingredients
                        ...section.ingredients.asMap().entries.map((entry) {
                          final ingredientIndex = entry.key;
                          final ingredient = entry.value;
                          final isSelected =
                              sectionSelected.contains(ingredientIndex);
                          final (dispAmount, dispUnit) =
                              ingredient.displayAmountAndUnit;

                          return InkWell(
                            onTap: () => setState(() {
                              if (isSelected) {
                                _selected[sectionIndex]!
                                    .remove(ingredientIndex);
                              } else {
                                _selected[sectionIndex]!.add(ingredientIndex);
                              }
                            }),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: Row(
                                children: [
                                  Checkbox(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    value: isSelected,
                                    onChanged: (checked) => setState(() {
                                      if (checked == true) {
                                        _selected[sectionIndex]!
                                            .add(ingredientIndex);
                                      } else {
                                        _selected[sectionIndex]!
                                            .remove(ingredientIndex);
                                      }
                                    }),
                                  ),
                                  SizedBox(
                                    width: 65,
                                    child: Text(
                                      '$dispAmount $dispUnit'.trim(),
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
                        if (sectionIndex < resolvedSections.length - 1)
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
                          for (final entry in _selected.entries) {
                            for (final i in entry.value) {
                              ingredients.add(
                                  resolvedSections[entry.key].ingredients[i]);
                            }
                          }
                          context.router.pop();
                          ref
                              .read(shoppingListActionsProvider.notifier)
                              .addItemsFromIngredients(ingredients);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${ingredients.length} Zutaten zur Einkaufsliste hinzugefügt',
                              ),
                            ),
                          );
                        },
                  child: Text('Hinzufügen ($totalSelected Zutaten)'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
