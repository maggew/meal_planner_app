import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

const int maxPortionsNumber = 12;

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
    final List<int> possiblePortions = [
      for (int i = 0; i < maxPortionsNumber; i++) i + 1
    ];
    final selectedPortions = ref.watch(selectedPortionsProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        Text(
          "Portionen: ",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(
          width: 100,
          child: DropdownMenu<int>(
            enableSearch: false,
            enableFilter: false,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: colorScheme.surfaceContainer,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              )),
            ),
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: possiblePortions
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
