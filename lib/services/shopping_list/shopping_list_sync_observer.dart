import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_sync_provider.dart';

class ShoppingListSyncObserver extends WidgetsBindingObserver {
  final WidgetRef ref;
  ShoppingListSyncObserver(this.ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(shoppingListSyncServiceProvider).sync();
    }
  }
}
