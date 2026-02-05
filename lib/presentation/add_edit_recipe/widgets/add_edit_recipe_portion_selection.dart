import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

const int MAX_PORTION_NUMBER = 12;

class AddEditRecipePortionSelection extends ConsumerStatefulWidget {
  const AddEditRecipePortionSelection({
    super.key,
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
    final double porstionButtonWidth = 100;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Portionen: ",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        Gap(10),
        SizedBox(
          width: porstionButtonWidth,
          child: DropdownMenu<int>(
            inputDecorationTheme: const InputDecorationTheme(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(),
            ),
            enableSearch: false,
            enableFilter: false,
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: possiblePorstions
                .map((number) => DropdownMenuEntry(
                      value: number,
                      label: number.toString(),
                    ))
                .toList(),
            initialSelection: selectedPortions,
            onSelected: (portions) {
              if (portions != null) {
                ref.read(selectedPortionsProvider.notifier).set(portions);
              }
            },
          ),
        ),
      ],
    );
  }
}
