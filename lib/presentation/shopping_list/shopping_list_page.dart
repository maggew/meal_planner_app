import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/shopping_list/widgets/shopping_list_body.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_provider.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_realtime_service_provider.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_sync_provider.dart';
import 'package:meal_planner/services/shopping_list/shopping_list_realtime_service.dart';

@RoutePage()
class ShoppingListPage extends ConsumerStatefulWidget {
  const ShoppingListPage({super.key});

  @override
  ConsumerState<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends ConsumerState<ShoppingListPage> {
  ShoppingListRealtimeService? _realtimeService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shoppingListSyncServiceProvider).sync();
      _realtimeService = ref.read(shoppingListRealtimeServiceProvider);
      _realtimeService!.subscribe();
    });
  }

  @override
  void dispose() {
    _realtimeService?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(
        title: "Einkaufsliste",
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
