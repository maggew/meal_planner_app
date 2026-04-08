import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/enums/shopping_list_view_mode.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/presentation/shopping_list/widgets/shopping_list_body.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_provider.dart';
import 'package:meal_planner/services/providers/sync/sync_providers.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';

@RoutePage()
class ShoppingListPage extends ConsumerStatefulWidget {
  const ShoppingListPage({super.key});

  @override
  ConsumerState<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends ConsumerState<ShoppingListPage> {
  TabsRouter? _tabsRouter;
  bool _polling = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = AutoTabsRouter.of(context);
    if (_tabsRouter != router) {
      _tabsRouter?.removeListener(_onTabChange);
      _tabsRouter = router;
      _tabsRouter!.addListener(_onTabChange);
      _onTabChange();
    }
  }

  void _onTabChange() {
    final router = _tabsRouter;
    if (router == null) return;
    final isActive = router.current.name == ShoppingListRoute.name;
    if (isActive && !_polling) {
      _polling = true;
      ref.read(syncCoordinatorProvider).enableShoppingListPolling();
    } else if (!isActive && _polling) {
      _polling = false;
      ref.read(syncCoordinatorProvider).disableShoppingListPolling();
    }
  }

  @override
  void dispose() {
    _tabsRouter?.removeListener(_onTabChange);
    if (_polling) {
      ref.read(syncCoordinatorProvider).disableShoppingListPolling();
    }
    super.dispose();
  }

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
          IconButton(
            icon: Icon(
              ref.watch(userSettingsProvider
                      .select((s) => s.shoppingListViewMode)) ==
                  ShoppingListViewMode.grid
                  ? Icons.view_list
                  : Icons.grid_view,
            ),
            onPressed: () {
              final current = ref.read(userSettingsProvider)
                  .shoppingListViewMode;
              ref
                  .read(userSettingsProvider.notifier)
                  .updateShoppingListViewMode(
                    current == ShoppingListViewMode.grid
                        ? ShoppingListViewMode.list
                        : ShoppingListViewMode.grid,
                  );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'remove_checked') {
                ref
                    .read(shoppingListActionsProvider.notifier)
                    .removeCheckedItems();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'remove_checked',
                child: Text('Abgehakte entfernen'),
              ),
            ],
          ),
        ],
      ),
      scaffoldBody: ShoppingListBody(),
    );
  }
}
