import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/data/repositories/supabase_shopping_list_repository.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/shopping_list/shopping_list_sync_service.dart';

final shoppingListSyncServiceProvider =
    Provider<ShoppingListSyncService>((ref) {
  final session = ref.watch(sessionProvider);
  final groupId = session.groupId ?? '';
  return ShoppingListSyncService(
    dao: ref.watch(shoppingItemDaoProvider),
    remote: SupabaseShoppingListRepository(
      supabase: ref.watch(supabaseProvider),
      groupId: groupId,
    ),
    groupId: groupId,
  );
});
