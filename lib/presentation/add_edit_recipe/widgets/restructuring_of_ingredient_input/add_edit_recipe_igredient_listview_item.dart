import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';

class AddEditRecipeIgredientListviewItem extends ConsumerWidget {
  final int index;
  final Ingredient ingredient;
  final TextEditingController amountController;
  final DropdownController<Unit> unitDropdownController;
  final List<CoolDropdownItem<Unit>> unitDropdownItems;
  final TextEditingController ingredientNameController;
  final VoidCallback onDelete;
  const AddEditRecipeIgredientListviewItem({
    super.key,
    required this.index,
    required this.ingredient,
    required this.amountController,
    required this.ingredientNameController,
    required this.unitDropdownItems,
    required this.unitDropdownController,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
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
                      label: Text("Zutat"),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
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
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: true), // Wichtig!
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      label: Text("Menge"),
                    ),
                  ),
                ),
                Gap(10),
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
              ],
            )
          ],
        ),
      ),
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
