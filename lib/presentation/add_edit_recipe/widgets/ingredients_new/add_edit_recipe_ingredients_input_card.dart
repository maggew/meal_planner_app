import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_form_item.dart';

class AddEditRecipeIngredientsInputCard extends ConsumerStatefulWidget {
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
  ConsumerState<AddEditRecipeIngredientsInputCard> createState() =>
      _AddEditRecipeIngredientsInputCardState();
}

class _AddEditRecipeIngredientsInputCardState
    extends ConsumerState<AddEditRecipeIngredientsInputCard> {
  late final FocusNode _nameFocusNode;

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();

    if (widget.item.shouldRequestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _nameFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final BorderRadius borderRadius = widget.isFinalItem
        ? BorderRadius.vertical(bottom: Radius.circular(8))
        : BorderRadius.zero;
    final Border? border =
        widget.isFinalItem ? null : Border(bottom: BorderSide(width: 1));
    final MenuController _dropdownMenuController = MenuController();
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
                    controller: widget.item.nameController,
                    focusNode: _nameFocusNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Zutat',
                      hintText: 'Zutat eingeben…',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: widget.onDelete,
                ),
              ],
            ),

            const Gap(6),

            // ---------------- Amount + Unit ----------------
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.item.amountController,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      // unfocus for keyboard to disappear
                      FocusScope.of(context).unfocus();
                      // dropdownMenu opens
                      _dropdownMenuController.open();
                    },
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
                        widget.item.amountController.value =
                            widget.item.amountController.value.copyWith(
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
                  width: 120,
                  child: DropdownMenu<Unit>(
                    menuController: _dropdownMenuController,
                    label: Text("Einheit"),
                    enableSearch: false,
                    enableFilter: false,
                    expandedInsets: EdgeInsets.zero,
                    dropdownMenuEntries: _unitDropdownMenuEntries,
                    initialSelection: widget.item.unit,
                    onSelected: (unit) {
                      if (unit != null) {
                        widget.onUnitChanged(unit);
                      }
                    },
                  ),
                ),
                const Gap(10),
                IconButton(
                  onPressed: () => widget.onChecked(),
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

final _unitDropdownMenuEntries = Unit.values
    .map(
      (unit) => DropdownMenuEntry<Unit>(
        value: unit,
        label: unit.displayName,
      ),
    )
    .toList();
