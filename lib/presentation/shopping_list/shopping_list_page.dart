import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/data/sync/sync_feature.dart';
import 'package:meal_planner/domain/enums/shopping_list_view_mode.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/common/sync_polling_mixin.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/presentation/shopping_list/widgets/shopping_list_body.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_provider.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';

@RoutePage()
class ShoppingListPage extends ConsumerStatefulWidget {
  const ShoppingListPage({super.key});

  @override
  ConsumerState<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends ConsumerState<ShoppingListPage>
    with SyncPollingMixin {
  @override
  SyncFeature get syncFeature => const ShoppingListSync();

  @override
  String get syncRouteName => ShoppingListRoute.name;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(
        title: "Einkaufsliste",
        automaticallyImplyLeading: false,
        actionsButtons: [
          if (!ref.watch(isOnlineProvider)) ...[
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.cloud_off),
            ),
          ],
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'remove_checked') {
                ref
                    .read(shoppingListActionsProvider.notifier)
                    .removeCheckedItems();
              } else if (value == 'toggle_view') {
                final current =
                    ref.read(userSettingsProvider).shoppingListViewMode;
                ref
                    .read(userSettingsProvider.notifier)
                    .updateShoppingListViewMode(
                      current == ShoppingListViewMode.grid
                          ? ShoppingListViewMode.list
                          : ShoppingListViewMode.grid,
                    );
              }
            },
            itemBuilder: (context) {
              final isGrid = ref.read(userSettingsProvider
                      .select((s) => s.shoppingListViewMode)) ==
                  ShoppingListViewMode.grid;
              return [
                PopupMenuItem(
                  value: 'toggle_view',
                  child: Row(
                    children: [
                      Icon(isGrid ? Icons.view_list : Icons.grid_view),
                      const SizedBox(width: 12),
                      Text(isGrid ? 'Listenansicht' : 'Rasteransicht'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove_checked',
                  child: Text('Abgehakte entfernen'),
                ),
              ];
            },
          ),
        ],
      ),
      scaffoldBody: ShoppingListBody(),
    );
  }
}
