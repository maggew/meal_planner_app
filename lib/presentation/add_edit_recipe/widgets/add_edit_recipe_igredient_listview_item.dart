import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';

class AddEditRecipeIgredientListviewItem extends StatelessWidget {
  final int index;
  final Ingredient ingredient;
  final TextEditingController amountController;
  final TextEditingController ingredientNameController;
  final VoidCallback onDelete;
  final void Function(String) onNameChanged;
  final void Function(double) onAmountchanged;
  final void Function(Unit) onUnitChanged;
  //final bool isDragging;
  const AddEditRecipeIgredientListviewItem({
    super.key,
    required this.index,
    required this.ingredient,
    required this.amountController,
    required this.ingredientNameController,
    required this.onDelete,
    required this.onNameChanged,
    required this.onAmountchanged,
    required this.onUnitChanged,
    // required this.isDragging,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ingredientNameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        label: Text("Zutat"),
                        hintText: "Zutat eingeben...",
                      ),
                      onChanged: onNameChanged,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
              Gap(5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        label: Text("Menge"),
                        hintText: "0",
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        // Komma durch Punkt ersetzen für Parsing
                        final normalized = value.replaceAll(',', '.');
                        final amount = double.tryParse(normalized) ?? 0;
                        onAmountchanged(amount);
                      },
                    ),
                  ),
                  Gap(10),
                  DropdownButton<Unit>(
                    value: ingredient.unit,
                    items: _unitDropdownItems,
                    onChanged: (value) {
                      if (value != null) {
                        onUnitChanged(value);
                      }
                    },
                  ),
                  Gap(10),
                  ReorderableDragStartListener(
                      child: Icon(
                        Icons.drag_handle,
                      ),
                      index: index)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

final _unitDropdownItems = Unit.values
    .map((unit) => DropdownMenuItem(
          value: unit,
          child: Text(unit.displayName),
        ))
    .toList();
