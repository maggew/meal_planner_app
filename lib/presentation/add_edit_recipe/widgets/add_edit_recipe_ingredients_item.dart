import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
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

    final ThemeData themeData = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Zutaten",
              style: themeData.textTheme.displayMedium,
            ),
            Gap(10),
            IconButton(
              onPressed: () {
                notifier.analyzeIngredientsFromImage(pickImageFromCamera: true);
              },
              icon: Icon(Icons.camera_alt_outlined),
            ),
            Gap(10),
            IconButton(
              onPressed: () {
                notifier.analyzeIngredientsFromImage(
                    pickImageFromCamera: false);
              },
              icon: Icon(Icons.folder_outlined),
            ),
          ],
        ),
        SizedBox(height: 10),
        LoadingOverlay(
          isLoading: state.isAnalyzing,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey, width: 1.5),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                ReorderableListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  buildDefaultDragHandles: false,
                  physics: const NeverScrollableScrollPhysics(),
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      elevation: 4,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      child: IgnorePointer(child: child),
                    );
                  },
                  // onReorderStart: (_) => _isDragging.value = true,
                  // onReorderEnd: (_) => _isDragging.value = false,
                  onReorder: notifier.reorder,
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    //print("building item $index");
                    final item = state.items[index];
                    return AddEditRecipeIgredientListviewItem(
                      key: ValueKey(item.ingredient.localId),
                      index: index,
                      amountController: item.amountController,
                      ingredient: item.ingredient,
                      ingredientNameController: item.nameController,
                      onDelete: () => notifier.deleteIngredient(index),
                      onNameChanged: (v) => notifier.updateName(index, v),
                      onAmountchanged: (v) => notifier.updateAmount(index, v),
                      onUnitChanged: (u) => notifier.updateUnit(index, u),
                    );
                  },
                ),
                ElevatedButton.icon(
                  onPressed: notifier.addIngredient,
                  icon: Icon(Icons.add),
                  label: Text('Zutat hinzufügen'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
