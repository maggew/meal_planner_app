import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';
import 'package:meal_planner/services/providers/groups/group_category_provider.dart';

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
    final categoriesAsync = ref.watch(groupCategoriesProvider);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          "Kategorien",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        categoriesAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => const SizedBox.shrink(),
          data: (categories) => SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: categories
                  .map((category) {
                        final isSelected =
                            selectedCategories.contains(category.id);
                        final colorScheme = Theme.of(context).colorScheme;
                        return FilterChip(
                          labelStyle: textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                          label: Text(category.name),
                          selected: isSelected,
                          selectedColor: colorScheme.primary,
                          checkmarkColor: colorScheme.onPrimary,
                          onSelected: (_) {
                            FocusScope.of(context).unfocus();
                            ref
                                .read(selectedCategoriesProvider.notifier)
                                .toggle(category.id);
                          },
                        );
                      })
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
