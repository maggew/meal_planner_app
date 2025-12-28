import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/categories.dart';
import 'package:meal_planner/services/providers/add_recipe_provider.dart';

class AddRecipeCategorySelection extends StatelessWidget {
  final DropdownController categoryDropdownController;
  final WidgetRef ref;
  const AddRecipeCategorySelection({
    super.key,
    required this.categoryDropdownController,
    required this.ref,
  });

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
          defaultItem: categoryDropdownItems[0],
          dropdownOptions: DropdownOptions(height: 290),
          onChange: (v) {
            ref.read(selectedCategoryProvider.notifier).state = v;
            categoryDropdownController.close();
          },
          controller: categoryDropdownController,
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
