import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_provider.dart';

class ShoppingListInput extends ConsumerStatefulWidget {
  const ShoppingListInput({super.key});

  @override
  ConsumerState<ShoppingListInput> createState() => _ShoppingListInputState();
}

class _ShoppingListInputState extends ConsumerState<ShoppingListInput> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref.read(shoppingListActionsProvider.notifier).addItem(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'z.B. 500g Mehl',
          fillColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          suffixIcon: IconButton(
            icon: const Icon(Icons.add),
            onPressed: _submit,
          ),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
    );
  }
}
