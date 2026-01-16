import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/categories.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

class AddEditRecipeCategorySelection extends ConsumerStatefulWidget {
  final List<String>? initialCategories;

  const AddEditRecipeCategorySelection({
    super.key,
    required this.initialCategories,
  });

  @override
  ConsumerState<AddEditRecipeCategorySelection> createState() =>
      _AddRecipeCategorySelection();
}

class _AddRecipeCategorySelection
    extends ConsumerState<AddEditRecipeCategorySelection> {
  @override
  Widget build(BuildContext context) {
    print("initialCategories: ${widget.initialCategories}");
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    print("selected categories: $selectedCategories");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kategorien",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: categoryNames
              .map((category) => FilterChip(
                    label: Text(category),
                    selected:
                        selectedCategories.contains(category.toLowerCase()),
                    onSelected: (_) {
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
