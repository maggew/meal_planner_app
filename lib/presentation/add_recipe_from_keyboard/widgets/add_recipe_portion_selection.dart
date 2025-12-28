import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/add_recipe_provider.dart';

const int MAX_PORTION_NUMBER = 8;

class AddRecipePortionSelection extends StatelessWidget {
  final DropdownController portionDropdownController;
  final WidgetRef ref;
  const AddRecipePortionSelection({
    super.key,
    required this.portionDropdownController,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    List<CoolDropdownItem<dynamic>> portionDropdownItems =
        getPortionDropdownItems();
    return Row(
      children: [
        Text(
          "Portionen: ",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          width: 50,
          child: CoolDropdown(
            onChange: (v) {
              ref.read(selectedPortionsProvider.notifier).state = v;
              portionDropdownController.close();
            },
            dropdownList: portionDropdownItems,
            defaultItem: portionDropdownItems[3],
            controller: portionDropdownController,
          ),
        ),
      ],
    );
  }
}

List<CoolDropdownItem<dynamic>> getPortionDropdownItems() {
  List<CoolDropdownItem<dynamic>> out = [];
  for (int i = 1; i < MAX_PORTION_NUMBER + 1; i++) {
    out.add(CoolDropdownItem(label: i.toString(), value: i));
  }
  return out;
}
