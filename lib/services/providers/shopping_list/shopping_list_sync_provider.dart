import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/data/repositories/offline_first_shopping_list_repository.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

final shoppingListSyncServiceProvider =
    Provider<OfflineFirstShoppingListRepository>((ref) {
  return ref.watch(offlineFirstShoppingListProvider);
});
