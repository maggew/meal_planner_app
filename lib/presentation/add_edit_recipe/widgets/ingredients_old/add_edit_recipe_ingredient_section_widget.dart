import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_form_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/ingredients_old/add_edit_recipe_igredient_listview_item.dart';
import 'package:meal_planner/services/providers/recipe/add_edit_recipe_ingredients_provider.dart';

class AddEditRecipeIngredientSectionWidget extends ConsumerWidget {
  final AddEditRecipeIngredientsProvider ingredientsProvider;
  final int sectionIndex;

  const AddEditRecipeIngredientSectionWidget({
    super.key,
    required this.ingredientsProvider,
    required this.sectionIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ingredientsProvider);
    final notifier = ref.read(ingredientsProvider.notifier);
    final section = state.sections[sectionIndex];

    final showTitle =
        state.sections.length > 1 || section.titleController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- Section Title ----------
        if (showTitle)
          TextField(
            controller: section.titleController,
            decoration: const InputDecoration(
              labelText: 'Abschnitt',
            ),
          ),

        const SizedBox(height: 8),

        // ---------- Ingredients ----------
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: section.items.length,
          onReorder: (oldIndex, newIndex) {
            notifier.reorderIngredient(
              sectionIndex,
              oldIndex,
              newIndex,
            );
          },
          itemBuilder: (context, itemIndex) {
            final IngredientFormItem item = section.items[itemIndex];

            return AddEditRecipeIgredientListviewItem(
              key: ValueKey(item),
              index: itemIndex,
              item: item,
              onUnitChanged: (unit) => notifier.changeUnit(
                  sectionIndex: sectionIndex, itemIndex: itemIndex, unit: unit),
              onDelete: () => notifier.deleteIngredient(
                sectionIndex,
                itemIndex,
              ),
            );
          },
        ),

        // ---------- Add Ingredient ----------
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => notifier.addIngredient(sectionIndex),
            icon: const Icon(Icons.add),
            label: const Text('Zutat hinzufügen'),
          ),
        ),

        const Divider(),
      ],
    );
  }
}
