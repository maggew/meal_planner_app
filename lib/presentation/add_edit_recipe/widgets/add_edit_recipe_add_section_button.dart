import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/recipe/add_edit_recipe_ingredients_provider.dart';

class AddEditRecipeAddSectionButton extends ConsumerWidget {
  final AddEditRecipeIngredientsProvider ingredientsProvider;

  const AddEditRecipeAddSectionButton({
    super.key,
    required this.ingredientsProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () {
        ref.read(ingredientsProvider.notifier).addSection();
      },
      icon: const Icon(Icons.add),
      label: const Text('Abschnitt hinzufügen'),
    );
  }
}
