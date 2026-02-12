import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/ingredients/add_edit_recipe_ingredients_list_widget.dart';
import 'package:meal_planner/services/providers/recipe/add_edit_recipe_ingredients_provider.dart';

class AddEditRecipeIngredientsWidget extends ConsumerWidget {
  final AddEditRecipeIngredientsProvider ingredientsProvider;
  const AddEditRecipeIngredientsWidget({
    super.key,
    required this.ingredientsProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- Header ----------
        Row(
          children: [
            Text(
              'Zutaten',
              style: textTheme.displayMedium,
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: () {
                ref
                    .watch(ingredientsProvider.notifier)
                    .analyzeIngredientsFromImage(pickImageFromCamera: true);
              },
            ),
            IconButton(
              icon: const Icon(Icons.folder_outlined),
              onPressed: () {
                ref
                    .watch(ingredientsProvider.notifier)
                    .analyzeIngredientsFromImage(pickImageFromCamera: false);
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        AddEditRecipeIngredientsListWidget(
            ingredientsProvider: ingredientsProvider),
      ],
    );
  }
}
