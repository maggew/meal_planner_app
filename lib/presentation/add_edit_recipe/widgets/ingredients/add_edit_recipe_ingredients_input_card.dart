import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_form_item.dart';

class AddEditRecipeIngredientsInputCard extends ConsumerStatefulWidget {
  final IngredientFormItem item;
  final void Function() onChecked;
  final void Function(Unit?) onUnitChanged;
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
  late final MenuController _dropdownMenuController;

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();
    _dropdownMenuController = MenuController();

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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final BorderRadius borderRadius = widget.isFinalItem
        ? BorderRadius.vertical(
            bottom: Radius.circular(AppDimensions.borderRadius))
        : BorderRadius.zero;
    final Border? border = widget.isFinalItem
        ? null
        : Border(
            bottom: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.3), width: 1));

    return AnimatedContainer(
      duration: AppDimensions.animationDuration,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: borderRadius,
        border: border,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          spacing: 10,
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
                    decoration: InputDecoration(
                      labelText: 'Zutat',
                      hintText: 'Zutat eingeben…',
                      fillColor: colorScheme.surface,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: colorScheme.error, size: 20),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            Row(
              spacing: 10,
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
                    decoration: InputDecoration(
                      labelText: 'Menge',
                      hintText: '0',
                      fillColor: colorScheme.surface,
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
                SizedBox(
                  width: 120,
                  child: DropdownMenu<Unit?>(
                    menuController: _dropdownMenuController,
                    label: Text("Einheit"),
                    enableSearch: false,
                    enableFilter: false,
                    expandedInsets: EdgeInsets.zero,
                    dropdownMenuEntries: _unitDropdownMenuEntries,
                    initialSelection: widget.item.unit,
                    onSelected: (unitSelection) =>
                        widget.onUnitChanged(unitSelection),
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => widget.onChecked(),
                  icon: Icon(
                    Icons.check,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final List<DropdownMenuEntry<Unit?>> _unitDropdownMenuEntries = [
  DropdownMenuEntry(value: null, label: "-"),
  ...Unit.values
      .map(
        (unit) => DropdownMenuEntry<Unit?>(
          value: unit,
          label: unit.displayName,
        ),
      )
      .toList()
];
