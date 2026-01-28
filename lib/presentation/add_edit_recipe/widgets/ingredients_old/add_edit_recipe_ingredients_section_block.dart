import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/ingredients_old/add_edit_recipe_ingredient_section_widget.dart';
import 'package:meal_planner/services/providers/recipe/add_edit_recipe_ingredients_provider.dart';

class AddEditRecipeIngredientsBlock extends ConsumerWidget {
  final AddEditRecipeIngredientsProvider ingredientsProvider;

  const AddEditRecipeIngredientsBlock({
    super.key,
    required this.ingredientsProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ingredientsProvider);
    final notifier = ref.read(ingredientsProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- Header ----------
        Row(
          children: [
            Text(
              'Zutaten',
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: () {
                notifier.analyzeIngredientsFromImage(
                  pickImageFromCamera: true,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.folder_outlined),
              onPressed: () {
                notifier.analyzeIngredientsFromImage(
                  pickImageFromCamera: false,
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ---------- Sections ----------
        ...List.generate(
          state.sections.length,
          (sectionIndex) => AddEditRecipeIngredientSectionWidget(
            ingredientsProvider: ingredientsProvider,
            sectionIndex: sectionIndex,
          ),
        ),

        // ---------- Add Section ----------
        TextButton.icon(
          onPressed: notifier.addSection,
          icon: const Icon(Icons.add),
          label: const Text('Abschnitt hinzufügen'),
        ),
      ],
    );
  }
}
