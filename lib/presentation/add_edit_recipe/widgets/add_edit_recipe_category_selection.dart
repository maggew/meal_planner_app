import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/categories.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

class AddEditRecipeCategorySelection extends ConsumerStatefulWidget {
  final DropdownController categoryDropdownController;
  final String? initialCategory;

  const AddEditRecipeCategorySelection({
    super.key,
    required this.categoryDropdownController,
    this.initialCategory,
  });

  @override
  ConsumerState<AddEditRecipeCategorySelection> createState() =>
      _AddRecipeCategorySelection();
}

class _AddRecipeCategorySelection
    extends ConsumerState<AddEditRecipeCategorySelection> {
  @override
  Widget build(BuildContext context) {
    List<CoolDropdownItem<dynamic>> categoryDropdownItems =
        getCategoryDropdownItems();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kategorie",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(height: 10),
        CoolDropdown(
          dropdownList: categoryDropdownItems,
          defaultItem: categoryDropdownItems.firstWhere(
              (category) =>
                  category.value.toString().toLowerCase() ==
                  widget.initialCategory?.toLowerCase(),
              orElse: () => categoryDropdownItems[0]),
          dropdownOptions: DropdownOptions(height: 290),
          onChange: (v) {
            ref.read(selectedCategoryProvider.notifier).state = v.value;
            widget.categoryDropdownController.close();
          },
          controller: widget.categoryDropdownController,
          isMarquee: true,
        ),
      ],
    );
  }
}

List<CoolDropdownItem<dynamic>> getCategoryDropdownItems() {
  List<CoolDropdownItem<dynamic>> out = [];
  for (int i = 0; i < categoryNames.length; i++) {
    out.add(CoolDropdownItem(label: categoryNames[i], value: categoryNames[i]));
  }
  return out;
}
