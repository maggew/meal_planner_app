import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/services/providers/add_recipe_provider.dart';

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
        //     SizedBox(width: 3),
        //     Tooltip(
        //       padding: EdgeInsets.all(8),
        //       margin: EdgeInsets.only(left: 20, right: 20),
        //       textStyle: TextStyle(
        //         fontSize: 15,
        //         fontFamily: GoogleFonts.aBeeZee().fontFamily,
        //       ),
        //       decoration: BoxDecoration(
        //         color: Colors.pink[100],
        //         borderRadius: BorderRadius.all(Radius.circular(10)),
        //       ),
        //       preferBelow: false,
        //       triggerMode: TooltipTriggerMode.tap,
        //       showDuration: Duration(seconds: 5),
        //       message: Text(
        //         "Bitte verwende ausschließlich gängige "
        //         "Bezeichnungen für die Einheit deiner Zutaten:"
        //         "\n\ng, kg, l, ml, TL, EL, Stück, Prise, Msp, Bund",
        //         maxLines: 3,
        //       ).data,
        //       child: Padding(
        //           padding: EdgeInsets.only(top: 2.5),
        //           child: Icon(Icons.info_outline)),
        //     ),
        //   ],
        // ),
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

                    return DataRow2(
                      cells: [
                        // Zutat Name
                        DataCell(
                          TextField(
                            controller:
                                TextEditingController(text: ingredient.name)
                                  ..selection = TextSelection.collapsed(
                                    offset: ingredient.name.length,
                                  ),
                            onChanged: (value) {
                              ref
                                  .read(ingredientsProvider.notifier)
                                  .updateIngredient(
                                    index,
                                    name: value,
                                  );
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Zutat eingeben...',
                            ),
                          ),
                        ),

                        // Menge
                        DataCell(
                          TextField(
                            controller: TextEditingController(
                              text: ingredient.amount == 0
                                  ? ''
                                  : ingredient.amount.toString(),
                            )..selection = TextSelection.collapsed(
                                offset: ingredient.amount == 0
                                    ? 0
                                    : ingredient.amount.toString().length,
                              ),
                            onChanged: (value) {
                              final amount = int.tryParse(value) ?? 0;
                              ref
                                  .read(ingredientsProvider.notifier)
                                  .updateIngredient(
                                    index,
                                    amount: amount,
                                  );
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                            ),
                          ),
                        ),

                        // Einheit (Dropdown)
                        DataCell(
                          CoolDropdown<Unit>(
                            controller: _getOrCreateController(index),
                            dropdownList: unitDropdownItems,
                            defaultItem: unitDropdownItems.firstWhere(
                              (item) => item.value == ingredient.unit,
                              orElse: () => unitDropdownItems[0],
                            ),
                            onChange: (selectedItem) {
                              ref
                                  .read(ingredientsProvider.notifier)
                                  .updateIngredient(
                                    index,
                                    unit: selectedItem,
                                  );
                              _getOrCreateController(index).close();
                            },
                            resultOptions: ResultOptions(
                              width: 80,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                            ),
                            dropdownOptions: DropdownOptions(
                              width: 120,
                            ),
                          ),
                        ),

                        // Löschen-Button
                        DataCell(
                          IconButton(
                            icon:
                                Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () {
                              dropdownControllers[index]?.dispose();
                              dropdownControllers.remove(index);
                              ref
                                  .read(ingredientsProvider.notifier)
                                  .deleteIngredient(index);
                            },
                          ),
                        ),
                      ],
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
