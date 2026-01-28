import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_form_item.dart';

class AddEditRecipeIngredientsInputCard extends ConsumerWidget {
  final IngredientFormItem item;
  final void Function() onChecked;
  final void Function(Unit) onUnitChanged;
  final VoidCallback onDelete;
  final bool isFinalItem;
  const AddEditRecipeIngredientsInputCard({
    super.key,
    required this.item,
    required this.onChecked,
    required this.onUnitChanged,
    required this.onDelete,
    required this.isFinalItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final BorderRadius borderRadius = isFinalItem
        ? BorderRadius.vertical(bottom: Radius.circular(8))
        : BorderRadius.zero;
    final Border? border =
        isFinalItem ? null : Border(bottom: BorderSide(width: 1));
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: borderRadius,
        border: border,
      ),
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
                IconButton(
                  onPressed: () => onChecked(),
                  icon: Icon(Icons.check),
                ),
              ],
            ),
          ],
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
