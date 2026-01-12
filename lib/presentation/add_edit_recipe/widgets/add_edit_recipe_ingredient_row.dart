import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

DataRow2 buildIngredientRow({
  required int index,
  required Ingredient ingredient,
  required List<CoolDropdownItem<Unit>> unitDropdownItems,
  required WidgetRef ref,
  required DropdownController<Unit> unitDropdownController,
  required Map<int, DropdownController<Unit>> dropdownControllerMap,
  required TextEditingController amountController,
  required Map<int, TextEditingController> amountControllerMap,
  required TextEditingController ingredientNameController,
  required Map<int, TextEditingController> ingredientNameControllerMap,
}) {
  return DataRow2(
    specificRowHeight: 60,
    cells: [
      // Zutat Name
      DataCell(
        TextField(
          controller: ingredientNameController,
          onChanged: (value) {
            ref.read(ingredientsProvider.notifier).updateIngredient(
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
          controller: amountController,
          onChanged: (value) {
            // Komma durch Punkt ersetzen für Parsing
            final normalized = value.replaceAll(',', '.');
            final amount = double.tryParse(normalized) ?? 0;
            ref.read(ingredientsProvider.notifier).updateIngredient(
                  index,
                  amount: amount,
                );
          },
          keyboardType:
              TextInputType.numberWithOptions(decimal: true), // Wichtig!
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '0',
          ),
        ),
      ),

      // Einheit (Dropdown)
      DataCell(
        CoolDropdown<Unit>(
          controller: unitDropdownController,
          dropdownList: unitDropdownItems,
          defaultItem: unitDropdownItems.firstWhere(
            (item) => item.value == ingredient.unit,
            orElse: () => unitDropdownItems[0],
          ),
          onChange: (selectedItem) {
            ref.read(ingredientsProvider.notifier).updateIngredient(
                  index,
                  unit: selectedItem,
                );
            unitDropdownController.close();
          },
          resultOptions: ResultOptions(
            width: 80,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          dropdownOptions: DropdownOptions(
            width: 120,
          ),
        ),
      ),

      // Löschen-Button
      DataCell(
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () {
            unitDropdownController.dispose();
            dropdownControllerMap.remove(index);
            amountControllerMap.remove(index);
            ingredientNameControllerMap.remove(index);
            ref.read(ingredientsProvider.notifier).deleteIngredient(index);
          },
        ),
      ),
    ],
  );
}
