import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/data/repositories/supabase_shopping_list_repository.dart';
import 'package:meal_planner/data/sync/meal_plan_sync_adapter.dart';
import 'package:meal_planner/data/sync/shopping_list_sync_adapter.dart';
import 'package:meal_planner/data/sync/sync_coordinator.dart';
import 'package:meal_planner/data/sync/sync_engine.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

/// Single shared engine for all features.
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final dao = ref.watch(appDatabaseProvider).syncMetaDao;
  final engine = SyncEngine(dao);
  ref.onDispose(engine.dispose);
  return engine;
});

final mealPlanSyncAdapterProvider = Provider<MealPlanSyncAdapter>((ref) {
  final groupId = ref.watch(sessionProvider.select((s) => s.groupId)) ?? '';
  return MealPlanSyncAdapter(
    dao: ref.watch(mealPlanDaoProvider),
    supabase: ref.watch(supabaseProvider),
    groupId: groupId,
  );
});

final shoppingListSyncAdapterProvider =
    Provider<ShoppingListSyncAdapter>((ref) {
  final groupId = ref.watch(sessionProvider.select((s) => s.groupId)) ?? '';
  return ShoppingListSyncAdapter(
    dao: ref.watch(shoppingItemDaoProvider),
    remote: SupabaseShoppingListRepository(
      supabase: ref.watch(supabaseProvider),
      groupId: groupId,
    ),
    groupId: groupId,
  );
});

/// Coordinator owns all sync triggers (timers, lifecycle, connectivity).
/// Pages should `enable*Polling` in `initState` and `disable*Polling` in
/// `dispose`. Call `start()` once from app bootstrap (in `main.dart`).
final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  final coordinator = SyncCoordinator(
    engine: ref.watch(syncEngineProvider),
    mealPlan: ref.watch(mealPlanSyncAdapterProvider),
    shopping: ref.watch(shoppingListSyncAdapterProvider),
  );
  ref.onDispose(coordinator.stop);
  return coordinator;
});
