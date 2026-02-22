import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/categories.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

class AddEditRecipeCategorySelection extends ConsumerStatefulWidget {
  const AddEditRecipeCategorySelection({
    super.key,
  });

  @override
  ConsumerState<AddEditRecipeCategorySelection> createState() =>
      _AddRecipeCategorySelection();
}

class _AddRecipeCategorySelection
    extends ConsumerState<AddEditRecipeCategorySelection> {
  @override
  Widget build(BuildContext context) {
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          "Kategorien",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: categoryNames
              .map((category) => FilterChip(
                    labelStyle: textTheme.bodyMedium,
                    label: Text(category),
                    selected:
                        selectedCategories.contains(category.toLowerCase()),
                    onSelected: (_) {
                      // unfocus textformfield
                      FocusScope.of(context).unfocus();
                      // toggle filterchip
                      ref
                          .read(selectedCategoriesProvider.notifier)
                          .toggle(category.toLowerCase());
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }
}
