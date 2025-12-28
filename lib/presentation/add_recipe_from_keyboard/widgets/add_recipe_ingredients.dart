import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/model/enums/unit.dart';
import 'package:meal_planner/services/providers/add_recipe_provider.dart';

class AddRecipeIngredients extends StatelessWidget {
  final DropdownController unitDropdownController;
  final WidgetRef ref;
  //final GlobalKey<EditableState> ingredientTable;
  const AddRecipeIngredients({
    super.key,
    //required this.ingredientTable,
    required this.unitDropdownController,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    List<CoolDropdownItem<Unit>> _unitDropdownItems = getUnitDropdownItems();
    return Column(
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
          child: DataTable2(
            horizontalMargin: 10,
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
            ],
            rows: [
              DataRow2(
                cells: [
                  DataCell(TextField(
                      decoration: InputDecoration(hintText: 'Zutat'))),
                  DataCell(
                      TextField(decoration: InputDecoration(hintText: '0'))),
                  DataCell(
                    CoolDropdown(
                      defaultItem: _unitDropdownItems[2],
                      dropdownList: _unitDropdownItems,
                      controller: unitDropdownController,
                      onChange: (v) {
                        ref.read(selectedUnitProvider.notifier).state = v;
                        unitDropdownController.close();
                      },
                    ),
                  ),
                ],
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
