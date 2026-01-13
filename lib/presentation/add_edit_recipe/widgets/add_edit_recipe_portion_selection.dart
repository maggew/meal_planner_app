import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

const int MAX_PORTION_NUMBER = 8;

class AddEditRecipePortionSelection extends ConsumerStatefulWidget {
  final DropdownController portionDropdownController;
  final int? initialPortions;

  const AddEditRecipePortionSelection({
    super.key,
    required this.portionDropdownController,
    required this.initialPortions,
  });

  @override
  ConsumerState<AddEditRecipePortionSelection> createState() =>
      _AddRecipePortionSelection();
}

class _AddRecipePortionSelection
    extends ConsumerState<AddEditRecipePortionSelection> {
  @override
  Widget build(BuildContext context) {
    List<CoolDropdownItem<int>> portionDropdownItems =
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
              widget.portionDropdownController.close();
            },
            dropdownList: portionDropdownItems,
            defaultItem: portionDropdownItems.firstWhere(
                (portions) => portions.value == widget.initialPortions,
                orElse: () => portionDropdownItems[3]),
            controller: widget.portionDropdownController,
          ),
        ),
      ],
    );
  }
}

List<CoolDropdownItem<int>> getPortionDropdownItems() {
  List<CoolDropdownItem<int>> out = [];
  for (int i = 1; i < MAX_PORTION_NUMBER + 1; i++) {
    out.add(CoolDropdownItem(label: i.toString(), value: i));
  }
  return out;
}
