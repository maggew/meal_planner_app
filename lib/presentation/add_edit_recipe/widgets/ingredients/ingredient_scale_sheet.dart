import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/services/amount_scaler.dart';
import 'package:meal_planner/presentation/common/display_ingredient.dart';

class _IngredientRef {
  final int sectionIndex;
  final int itemIndex;
  final Ingredient ingredient;
  final bool isSelectable;

  _IngredientRef({
    required this.sectionIndex,
    required this.itemIndex,
    required this.ingredient,
    required this.isSelectable,
  });
}

void showIngredientScaleSheet({
  required BuildContext context,
  required List<({List<({Ingredient ingredient, int itemIndex, int sectionIndex})> items})> sections,
  required void Function({
    required int sectionIndex,
    required int itemIndex,
    required String newAmount,
    required double factor,
  }) onScale,
}) {
  final ingredients = <_IngredientRef>[];
  for (final section in sections) {
    for (final item in section.items) {
      ingredients.add(_IngredientRef(
        sectionIndex: item.sectionIndex,
        itemIndex: item.itemIndex,
        ingredient: item.ingredient,
        isSelectable: item.ingredient.amount != null &&
            item.ingredient.amount!.trim().isNotEmpty &&
            AmountScaler.tryParse(item.ingredient.amount!) != null,
      ));
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      child: _IngredientScaleSheet(
        ingredients: ingredients,
        onScale: onScale,
      ),
    ),
  );
}

class _IngredientScaleSheet extends StatefulWidget {
  final List<_IngredientRef> ingredients;
  final void Function({
    required int sectionIndex,
    required int itemIndex,
    required String newAmount,
    required double factor,
  }) onScale;

  const _IngredientScaleSheet({
    required this.ingredients,
    required this.onScale,
  });

  @override
  State<_IngredientScaleSheet> createState() => _IngredientScaleSheetState();
}

class _IngredientScaleSheetState extends State<_IngredientScaleSheet> {
  int? _selectedIndex;
  final _amountController = TextEditingController();
  double? _factor;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectIngredient(int index) {
    final ref = widget.ingredients[index];
    setState(() {
      _selectedIndex = index;
      _amountController.text = ref.ingredient.amount ?? '';
      _factor = null;
    });
  }

  void _onAmountChanged(String value) {
    final ref = widget.ingredients[_selectedIndex!];
    final oldValue = AmountScaler.tryParse(ref.ingredient.amount!);
    final newValue = AmountScaler.tryParse(value);

    setState(() {
      if (oldValue != null &&
          newValue != null &&
          oldValue > 0 &&
          newValue > 0 &&
          (newValue - oldValue).abs() > 0.001) {
        _factor = newValue / oldValue;
      } else {
        _factor = null;
      }
    });
  }

  void _apply() {
    if (_selectedIndex == null || _factor == null) return;

    final ref = widget.ingredients[_selectedIndex!];
    widget.onScale(
      sectionIndex: ref.sectionIndex,
      itemIndex: ref.itemIndex,
      newAmount: _amountController.text.trim(),
      factor: _factor!,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenMargin,
        12,
        AppDimensions.screenMargin,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text('Mengen anpassen', style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Wähle eine Zutat als Referenz und gib die neue Menge ein.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          // Ingredient list
          Flexible(
            child: RadioGroup<int>(
              groupValue: _selectedIndex ?? -1,
              onChanged: (value) {
                if (value != null && value >= 0) _selectIngredient(value);
              },
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.ingredients.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, indent: 48),
                itemBuilder: (context, index) {
                  final ref = widget.ingredients[index];
                  final isSelected = _selectedIndex == index;

                  // Show scaled preview for non-selected items
                  final displayIngredient =
                      (!isSelected && _factor != null)
                          ? ref.ingredient.scale(_factor!)
                          : ref.ingredient;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: ref.isSelectable
                            ? () => _selectIngredient(index)
                            : null,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.borderRadius),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: ref.isSelectable
                                    ? Radio<int>(value: index)
                                    : const SizedBox.shrink(),
                              ),
                              Expanded(
                                child: Opacity(
                                  opacity: ref.isSelectable ? 1.0 : 0.5,
                                  child: DisplayIngredient(
                                      ingredient: displayIngredient),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Amount input for selected ingredient
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 48, right: 8, bottom: 8),
                          child: TextField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Neue Menge',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            onChanged: _onAmountChanged,
                            autofocus: true,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _factor != null ? _apply : null,
              child: Text(
                _factor != null
                    ? 'Anpassen (\u00d7${_factor!.toStringAsFixed(2)})'
                    : 'Anpassen',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
