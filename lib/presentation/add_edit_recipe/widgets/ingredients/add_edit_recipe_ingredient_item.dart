import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
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
    final ColorScheme colorsScheme = Theme.of(context).colorScheme;
    final BorderRadius borderRadius = isFinalItem
        ? BorderRadius.vertical(
            bottom: Radius.circular(AppDimensions.borderRadius))
        : BorderRadius.zero;
    final Border? border = isFinalItem
        ? null
        : Border(
            bottom: BorderSide(
              width: 1,
              color: colorsScheme.onSurface.withValues(alpha: 0.3),
            ),
          );
    return AnimatedContainer(
      duration: AppDimensions.animationDuration,
      decoration: BoxDecoration(
        color: colorsScheme.surfaceContainer,
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
              icon: Icon(
                Icons.delete,
                color: colorsScheme.error,
              )),
          ReorderableDragStartListener(
            index: flatIndex,
            child: const Icon(Icons.drag_handle),
          ),
        ],
      ),
    );
  }
}
