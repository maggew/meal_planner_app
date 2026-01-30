import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/flat_list_item.dart';
import 'package:meal_planner/presentation/common/display_ingredient.dart';
import 'package:meal_planner/services/providers/recipe/add_edit_recipe_ingredients_provider.dart';

class AddEditRecipeIngredientItem extends ConsumerWidget {
  final FlatListItem itemData;
  final int flatIndex;
  final bool isFinalItem;
  final AddEditRecipeIngredientsProvider ingredientsProvider;
  const AddEditRecipeIngredientItem({
    super.key,
    required this.itemData,
    required this.flatIndex,
    required this.isFinalItem,
    required this.ingredientsProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BorderRadius borderRadius = isFinalItem
        ? BorderRadius.vertical(bottom: Radius.circular(8))
        : BorderRadius.zero;
    final Border? border =
        isFinalItem ? null : Border(bottom: BorderSide(width: 1));
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        borderRadius: borderRadius,
        border: border,
      ),
      key: ValueKey(itemData.item),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: DisplayIngredient(
              ingredient: itemData.item!.ingredient,
            ),
          ),
          IconButton(
              onPressed: () {
                ref
                    .read(ingredientsProvider.notifier)
                    .editIngredient(flatIndex);
              },
              icon: Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                ref
                    .read(ingredientsProvider.notifier)
                    .deleteIngredient(flatIndex);
              },
              icon: Icon(Icons.delete)),
          ReorderableDragStartListener(
            index: flatIndex,
            child: const Icon(Icons.drag_handle),
          ),
        ],
      ),
    );
  }
}
