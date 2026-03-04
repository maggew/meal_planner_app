import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';

class IngredientInputWidget extends StatefulWidget {
  final List<String> ingredients;
  final ValueChanged<List<String>> onChanged;

  const IngredientInputWidget({
    super.key,
    required this.ingredients,
    required this.onChanged,
  });

  @override
  State<IngredientInputWidget> createState() => _IngredientInputWidgetState();
}

class _IngredientInputWidgetState extends State<IngredientInputWidget> {
  final _controller = TextEditingController();

  void _addIngredient() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (widget.ingredients.contains(text)) {
      _controller.clear();
      return;
    }
    widget.onChanged([...widget.ingredients, text]);
    _controller.clear();
  }

  void _removeIngredient(String ingredient) {
    widget.onChanged(
        widget.ingredients.where((i) => i != ingredient).toList());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Zutat eingeben...',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  isDense: true,
                ),
                onSubmitted: (_) => _addIngredient(),
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add),
              tooltip: 'Hinzufügen',
            ),
          ],
        ),
        if (widget.ingredients.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.ingredients.map((ingredient) {
              return Chip(
                label: Text(ingredient),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeIngredient(ingredient),
                backgroundColor:
                    colorScheme.secondaryContainer.withValues(alpha: 0.7),
                labelStyle:
                    TextStyle(color: colorScheme.onSecondaryContainer),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
