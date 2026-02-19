import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_provider.dart';

class ShoppingListItemTile extends ConsumerWidget {
  final ShoppingListItem item;

  const ShoppingListItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme _colorScheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: _colorScheme.error,
        child: Icon(Icons.delete, color: _colorScheme.onError),
      ),
      onDismissed: (_) {
        ref.read(shoppingListActionsProvider.notifier).removeItem(item.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(
          elevation: 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              ref
                  .read(shoppingListActionsProvider.notifier)
                  .toggleItem(item.id, !item.isChecked);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    item.isChecked ? Icons.check_circle : Icons.circle_outlined,
                    color: item.isChecked
                        ? _colorScheme.onSurface.withValues(alpha: 0.4)
                        : _colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      [
                        if (item.quantity != null) item.quantity!,
                        item.information,
                      ].join(' '),
                      style: TextStyle(
                        fontWeight:
                            item.quantity != null ? FontWeight.bold : null,
                        decoration:
                            item.isChecked ? TextDecoration.lineThrough : null,
                        color: item.isChecked
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
