import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_form_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/flat_list_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/ingredients_new/add_edit_recipe_ingredient_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/ingredients_new/add_edit_recipe_ingredients_input_card.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/ingredients_new/add_edit_recipe_section_header_item.dart';
import 'package:meal_planner/services/providers/recipe/add_edit_recipe_ingredients_provider.dart';

class AddEditRecipeIngredientsListWidget extends ConsumerWidget {
  final AddEditRecipeIngredientsProvider ingredientsProvider;
  const AddEditRecipeIngredientsListWidget(
      {super.key, required this.ingredientsProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ingredientsProvider);

    final List<FlatListItem> flatItems = [];
    for (int sectionIndex = 0;
        sectionIndex < state.sections.length;
        sectionIndex++) {
      final section = state.sections[sectionIndex];

      flatItems.add(
          FlatListItem.header(sectionIndex: sectionIndex, section: section));

      for (int itemIndex = 0; itemIndex < section.items.length; itemIndex++) {
        final IngredientFormItem item = section.items[itemIndex];
        flatItems.add(FlatListItem.ingredient(
            sectionIndex: sectionIndex, itemIndex: itemIndex, item: item));
      }

      // Button zum Hinzufügen eines neuen Ingredients in dieser Sektion
      flatItems.add(FlatListItem.addButton(sectionIndex: sectionIndex));
    }
    final int listLength = flatItems.length;

    return Card(
      elevation: 0,
      color: Colors.amber[100],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ReorderableListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: listLength,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Material(
                      elevation: 8,
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
              onReorder: (oldIndex, newIndex) {
                ref.read(ingredientsProvider.notifier).reorderIngredient(
                      oldIndex: oldIndex,
                      newIndex: newIndex,
                      flatItems: flatItems,
                    );
              },
              itemBuilder: (BuildContext, index) {
                final itemData = flatItems[index];
                switch (itemData.type) {
                  case FlatListItemType.header:
                    final bool sectionHasNoIngredient =
                        flatItems[index + 1].type == FlatListItemType.addButton;
                    return AddEditRecipeSectionHeaderItem(
                      key: ValueKey('section_${itemData.sectionIndex}'),
                      titleController: itemData.section!.titleController,
                      isEditable: itemData.section!.isEditable,
                      sectionHasNoIngredient: sectionHasNoIngredient,
                      onDeletePressed: () => _handleDeletePressed(context, ref,
                          ingredientsProvider, itemData.sectionIndex),
                      onEditPressed: () {
                        print("edit pressed...");
                        ref
                            .read(ingredientsProvider.notifier)
                            .editSectionTitle(itemData.sectionIndex);
                      },
                      onConfirmPressed: () {
                        FocusScope.of(context).unfocus();
                        print("confirm pressed...");
                        ref
                            .read(ingredientsProvider.notifier)
                            .confirmSectionTitle(itemData.sectionIndex);
                      },
                    );
                  case FlatListItemType.ingredient:
                    final item = itemData.item;
                    //final isFirstItem = itemData.itemIndex == 0;
                    final isFinalItem = itemData.itemIndex ==
                        state.sections[itemData.sectionIndex].items.length - 1;

                    if (item!.isEditable) {
                      return AddEditRecipeIngredientsInputCard(
                        key: ValueKey(item.id),
                        item: item,
                        isFinalItem: isFinalItem,
                        onDelete: () => ref
                            .read(ingredientsProvider.notifier)
                            .deleteIngredient(index),
                        onChecked: () {
                          // unfocus the textformfields
                          FocusScope.of(context).unfocus();
                          // Lock the current ingredient
                          ref
                              .read(ingredientsProvider.notifier)
                              .confirmIngredient(index);
                          // TODO: may use or maybe not
                          // // open new ingredient input field if at end of list
                          // if (isFinalItem) {
                          //   ref
                          //       .read(ingredientsProvider.notifier)
                          //       .addIngredient(itemData.sectionIndex);
                          // }
                        },
                        onUnitChanged: (unit) {
                          ref
                              .read(ingredientsProvider.notifier)
                              .changeUnit(flatIndex: index, unit: unit);
                        },
                      );
                    }

                    // Nicht editierbar - normales Display Widget
                    return AddEditRecipeIngredientItem(
                      key: ValueKey(item),
                      flatIndex: index,
                      itemData: itemData,
                      isFinalItem: isFinalItem,
                      ingredientsProvider: ingredientsProvider,
                    );
                  case FlatListItemType.addButton:
                    return ListTile(
                      key: ValueKey('add_btn_${itemData.sectionIndex}'),
                      dense: true,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.green),
                          Gap(10),
                          Text('Zutat hinzufügen'),
                        ],
                      ),
                      onTap: () {
                        ref
                            .read(ingredientsProvider.notifier)
                            .addIngredient(itemData.sectionIndex);
                      },
                    );
                }
              },
            ),
            SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(ingredientsProvider.notifier).addSection();
              },
              icon: Icon(Icons.add),
              label: Text('Neue Sektion hinzufügen'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _handleDeletePressed(
  BuildContext context,
  WidgetRef ref,
  AddEditRecipeIngredientsProvider ingredientsProvider,
  int sectionIndex,
) async {
  // 1. Bestätigungsdialog abholen
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sektion löschen'),
      content: const Text(
          'Möchtest du wirklich die Sektion löschen? \nAlle Zutaten darin werden gelöscht!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Löschen'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    ref.read(ingredientsProvider.notifier).removeSection(sectionIndex);
  }
}
