import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/shopping_list/shopping_list_realtime_service.dart';

final shoppingListRealtimeServiceProvider =
    Provider<ShoppingListRealtimeService>((ref) {
  final session = ref.watch(sessionProvider);
  return ShoppingListRealtimeService(
    supabase: ref.watch(supabaseProvider),
    dao: ref.watch(shoppingItemDaoProvider),
    groupId: session.groupId ?? '',
  );
});
