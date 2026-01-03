import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_ingredient_row.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

class AddRecipeIngredients extends ConsumerStatefulWidget {
  const AddRecipeIngredients({
    super.key,
  });
  @override
  ConsumerState<AddRecipeIngredients> createState() => _AddRecipeIngredients();
}

class _AddRecipeIngredients extends ConsumerState<AddRecipeIngredients> {
  final Map<int, DropdownController<Unit>> dropdownControllers = {};

  DropdownController<Unit> _getOrCreateController(int index) {
    if (!dropdownControllers.containsKey(index)) {
      dropdownControllers[index] = DropdownController();
    }
    return dropdownControllers[index]!;
  }

  @override
  void dispose() {
    dropdownControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(ingredientsProvider);

    if (ingredients.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(ingredientsProvider.notifier).addIngredient();
      });
    }
    final List<CoolDropdownItem<Unit>> unitDropdownItems =
        getUnitDropdownItems();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   children: [
        Text(
          "Zutaten",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey, width: 1.5),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          width: MediaQuery.of(context).size.width,
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: DataTable2(
                  horizontalMargin: 10,
                  dividerThickness: 2,
                  columnSpacing: 12,
                  isVerticalScrollBarVisible: true,
                  columns: [
                    DataColumn2(
                      label: Text('Zutat'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: Text('Menge'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: Text('Einheit'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text(''),
                      size: ColumnSize.S,
                    ),
                  ],
                  rows: ingredients.asMap().entries.map((entry) {
                    int index = entry.key;
                    Ingredient ingredient = entry.value;
                    return buildIngredientRow(
                      index: index,
                      ingredient: ingredient,
                      unitDropdownItems: unitDropdownItems,
                      ref: ref,
                      unitDropdownController: _getOrCreateController(index),
                      dropdownControllerMap: dropdownControllers,
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(ingredientsProvider.notifier).addIngredient();
                    },
                    icon: Icon(Icons.add),
                    label: Text('Zutat hinzufügen'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

List<CoolDropdownItem<Unit>> getUnitDropdownItems() {
  List<CoolDropdownItem<Unit>> out = [];
  for (Unit unit in Unit.values) {
    out.add(CoolDropdownItem(label: unit.displayName, value: unit));
  }
  return out;
}
