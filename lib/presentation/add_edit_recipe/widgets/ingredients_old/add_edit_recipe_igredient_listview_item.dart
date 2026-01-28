import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_form_item.dart';

class AddEditRecipeIgredientListviewItem extends StatelessWidget {
  final int index;
  final IngredientFormItem item;
  final void Function(Unit) onUnitChanged;
  final VoidCallback onDelete;

  const AddEditRecipeIgredientListviewItem({
    super.key,
    required this.index,
    required this.item,
    required this.onUnitChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // ---------------- Name ----------------
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: item.nameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Zutat',
                        hintText: 'Zutat eingeben…',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),

              const Gap(6),

              // ---------------- Amount + Unit ----------------
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: item.amountController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Menge',
                        hintText: '0',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        final normalized = value.replaceAll(',', '.');
                        if (normalized != value) {
                          item.amountController.value =
                              item.amountController.value.copyWith(
                            text: normalized,
                            selection: TextSelection.collapsed(
                                offset: normalized.length),
                          );
                        }
                      },
                    ),
                  ),
                  const Gap(10),
                  SizedBox(
                    width: 80,
                    child: DropdownButton<Unit>(
                      value: item.unit,
                      style: textTheme.bodyMedium,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _unitDropdownItems,
                      onChanged: (unit) {
                        if (unit != null) {
                          onUnitChanged(unit);
                        }
                      },
                    ),
                  ),
                  const Gap(10),
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _unitDropdownItems = Unit.values
    .map(
      (unit) => DropdownMenuItem<Unit>(
        value: unit,
        child: Text(unit.displayName),
      ),
    )
    .toList();
