import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

const int MAX_PORTION_NUMBER = 12;

class AddEditRecipePortionSelection extends ConsumerStatefulWidget {
  final int? initialPortions;

  const AddEditRecipePortionSelection({
    super.key,
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
    final List<int> possiblePorstions = [
      for (int i = 0; i < MAX_PORTION_NUMBER; i++) i + 1
    ];
    final selectedPortions = ref.watch(selectedPortionsProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Portionen: ",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        Gap(10),
        SizedBox(
          width: 75,
          child: DropdownButtonFormField<int>(
            value: selectedPortions,
            isDense: true,
            items: possiblePorstions
                .map((number) => DropdownMenuItem(
                      value: number,
                      child: Text(number.toString()),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(selectedPortionsProvider.notifier).set(value);
              }
            },
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
