import 'package:drift/drift.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/shopping_item_dao.dart';
import 'package:meal_planner/data/repositories/supabase_shopping_list_repository.dart';

class ShoppingListSyncService {
  final ShoppingItemDao _dao;
  final SupabaseShoppingListRepository _remote;
  final String _groupId;

  ShoppingListSyncService({
    required ShoppingItemDao dao,
    required SupabaseShoppingListRepository remote,
    required String groupId,
  })  : _dao = dao,
        _remote = remote,
        _groupId = groupId;

  Future<void> syncPendingItems() async {
    final pending = await _dao.getPendingItems(_groupId);

    for (final item in pending) {
      try {
        switch (item.syncStatus) {
          case 'pendingCreate':
            final created =
                await _remote.addItem(item.information, item.quantity);
            await _dao.updateSyncStatus(item.localId, 'synced',
                remoteId: created.id);
          case 'pendingUpdate':
            if (item.remoteId == null) continue;
            await _remote.toggleItem(item.remoteId!, item.isChecked);
            await _dao.updateSyncStatus(item.localId, 'synced');

          case 'pendingDelete':
            if (item.remoteId != null) {
              await _remote.removeItem(item.remoteId!);
            }
            await _dao.hardDeleteItem(item.localId);
        }
      } catch (e) {
        continue;
      }
    }
  }

  Future<void> pullRemoteItems() async {
    try {
      final remoteItems = await _remote.getItems();

      final companions = remoteItems
          .map((item) => LocalShoppingItemsCompanion(
                localId: Value(item.id),
                remoteId: Value(item.id),
                groupId: Value(_groupId),
                information: Value(item.information),
                quantity: Value(item.quantity),
                isChecked: Value(item.isChecked),
                syncStatus: const Value('synced'),
                updatedAt: Value(DateTime.now()),
              ))
          .toList();

      await _dao.replaceAllSynced(_groupId, companions);
    } catch (e) {
      // Pull fehlgeschlagen – lokale Daten bleiben erhalten
    }
  }

  // Beide zusammen – wird bei App-Start und Reconnect aufgerufen
  Future<void> sync() async {
    await syncPendingItems();
    await pullRemoteItems();
  }
}
