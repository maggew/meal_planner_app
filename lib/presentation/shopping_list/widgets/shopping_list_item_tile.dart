import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:meal_planner/services/providers/shopping_list_provider.dart';

class ShoppingListItemTile extends ConsumerWidget {
  final ShoppingListItem item;

  const ShoppingListItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(shoppingListProvider.notifier).removeItem(item.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(
          elevation: 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              ref
                  .read(shoppingListProvider.notifier)
                  .toggleItem(item.id, !item.isChecked);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    item.isChecked ? Icons.check_circle : Icons.circle_outlined,
                    color: item.isChecked
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  if (item.quantity != null) ...[
                    Text(
                      item.quantity!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration:
                            item.isChecked ? TextDecoration.lineThrough : null,
                        color: item.isChecked ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      item.information,
                      style: TextStyle(
                        decoration:
                            item.isChecked ? TextDecoration.lineThrough : null,
                        color: item.isChecked ? Colors.grey : null,
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
