import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_igredient_listview_item.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/services/providers/recipe/add_edit_recipe_ingredients_provider.dart';

class AddEditRecipeIngredientsItem extends ConsumerWidget {
  final AddEditRecipeIngredientsProvider ingredientsProvider;

  const AddEditRecipeIngredientsItem({
    super.key,
    required this.ingredientsProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ingredientsProvider);
    final notifier = ref.read(ingredientsProvider.notifier);
    final theme = Theme.of(context);

    // 👉 wir zeigen nur die erste (Default-)Section
    final sectionIndex = 0;
    final section = state.sections[sectionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Zutaten",
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () => notifier.analyzeIngredientsFromImage(
                pickImageFromCamera: true,
              ),
              icon: const Icon(Icons.camera_alt_outlined),
            ),
            IconButton(
              onPressed: () => notifier.analyzeIngredientsFromImage(
                pickImageFromCamera: false,
              ),
              icon: const Icon(Icons.folder_outlined),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LoadingOverlay(
          isLoading: state.isAnalyzing,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey, width: 1.5),
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(3)),
            ),
            child: Column(
              children: [
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
                    final item = section.items[itemIndex];

                    return AddEditRecipeIgredientListviewItem(
                      key: ValueKey(item),
                      item: item,
                      index: itemIndex,
                      onDelete: () => notifier.deleteIngredient(
                        sectionIndex,
                        itemIndex,
                      ),
                    );
                  },
                ),
                ElevatedButton.icon(
                  onPressed: () => notifier.addIngredient(sectionIndex),
                  icon: const Icon(Icons.add),
                  label: const Text('Zutat hinzufügen'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
