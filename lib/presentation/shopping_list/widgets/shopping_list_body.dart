import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/shopping_list/widgets/shopping_list_input.dart';
import 'package:meal_planner/presentation/shopping_list/widgets/shopping_list_item_tile.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_provider.dart';

class ShoppingListBody extends ConsumerWidget {
  const ShoppingListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListState = ref.watch(shoppingListStreamProvider);

    return Column(
      children: [
        const ShoppingListInput(),
        Expanded(
          child: shoppingListState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Fehler: $error')),
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Text('Deine Einkaufsliste ist leer'),
                );
              }

              final unchecked = items.where((i) => !i.isChecked).toList();
              final checked = items.where((i) => i.isChecked).toList();

              return ListView(
                children: [
                  ...unchecked.map((item) => ShoppingListItemTile(item: item)),
                  if (checked.isNotEmpty) ...[
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text('Erledigt',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                      fontWeight: FontWeight.w600,
                                    ))),
                    ...checked.map((item) => ShoppingListItemTile(item: item)),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
