import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/enums/shopping_list_view_mode.dart';
import 'package:meal_planner/presentation/common/native_ad_widget.dart';
import 'package:meal_planner/presentation/shopping_list/widgets/shopping_list_input.dart';
import 'package:meal_planner/presentation/shopping_list/widgets/shopping_list_item_row.dart';
import 'package:meal_planner/presentation/shopping_list/widgets/shopping_list_item_tile.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_provider.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';

class ShoppingListBody extends ConsumerWidget {
  const ShoppingListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListState = ref.watch(shoppingListStreamProvider);
    final viewMode = ref.watch(userSettingsProvider
        .select((s) => s.shoppingListViewMode));

    return Column(
      children: [
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

              return CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: NativeAdWidget(),
                    ),
                  ),
                  if (viewMode == ShoppingListViewMode.grid)
                    _buildGridSliver(context, unchecked)
                  else
                    _buildListSliver(unchecked),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: NativeAdWidget(),
                    ),
                  ),
                  if (checked.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          'Erledigt',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ),
                    if (viewMode == ShoppingListViewMode.grid)
                      _buildGridSliver(context, checked,
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12))
                    else
                      _buildListSliver(checked,
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12)),
                  ],
                ],
              );
            },
          ),
        ),
        const ShoppingListInput(),
      ],
    );
  }

  Widget _buildGridSliver(
    BuildContext context,
    List items, {
    EdgeInsets padding = const EdgeInsets.all(12),
  }) {
    const gridPadding = 12.0;
    const maxItemWidth = 150.0;
    final availableWidth =
        MediaQuery.sizeOf(context).width - gridPadding * 2;
    final crossAxisCount =
        math.max(3, (availableWidth / maxItemWidth).ceil());

    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: items
            .map((item) => ShoppingListItemTile(
                key: ValueKey(item.id), item: item))
            .toList(),
      ),
    );
  }

  Widget _buildListSliver(
    List items, {
    EdgeInsets padding = const EdgeInsets.all(12),
  }) {
    return SliverPadding(
      padding: padding,
      sliver: SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ShoppingListItemRow(
          key: ValueKey(items[index].id),
          item: items[index],
        ),
      ),
    );
  }
}
