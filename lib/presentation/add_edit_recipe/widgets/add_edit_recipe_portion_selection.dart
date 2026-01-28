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
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final double porstionButtonWidth = 75;
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
          child: InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            child: Center(
              child: DropdownButton<int>(
                style: textTheme.bodyMedium,
                value: selectedPortions,
                menuWidth: porstionButtonWidth,
                //isExpanded: true,
                //isDense: true,
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
          ),
        ),
      ],
    );
  }
}
