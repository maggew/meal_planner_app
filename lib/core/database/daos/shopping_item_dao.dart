import 'package:drift/drift.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/tables/local_shopping_items_table.dart';
import 'package:meal_planner/data/sync/local_sync_status.dart';

part 'shopping_item_dao.g.dart';

@DriftAccessor(tables: [LocalShoppingItems])
class ShoppingItemDao extends DatabaseAccessor<AppDatabase>
    with _$ShoppingItemDaoMixin {
  ShoppingItemDao(super.db);

  // UI nutzt diesen Stream – reagiert automatisch auf Änderungen
  Stream<List<LocalShoppingItem>> watchItemsByGroup(String groupId) {
    return (select(localShoppingItems)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) =>
              t.syncStatus.equals(LocalSyncStatus.pendingDelete.dbValue).not()))
        .watch();
  }

  // Für den Sync-Service
  Future<List<LocalShoppingItem>> getPendingItems(String groupId) {
    return (select(localShoppingItems)
          ..where((t) => t.groupId.equals(groupId))
          ..where(
              (t) => t.syncStatus.equals(LocalSyncStatus.synced.dbValue).not()))
        .get();
  }

  /// Returns the remote ids of all locally-pending items (any non-`synced`
  /// status) that already have a remote counterpart. Used by `SyncEngine` to
  /// implement local-pending-wins on the pull phase.
  Future<Set<String>> getPendingRemoteIds(String groupId) async {
    final rows = await (select(localShoppingItems)
          ..where((t) => t.groupId.equals(groupId))
          ..where(
              (t) => t.syncStatus.equals(LocalSyncStatus.synced.dbValue).not())
          ..where((t) => t.remoteId.isNotNull()))
        .get();
    return rows.map((r) => r.remoteId!).toSet();
  }

  Future<LocalShoppingItem?> getItemByLocalId(String localId) {
    return (select(localShoppingItems)
          ..where((t) => t.localId.equals(localId)))
        .getSingleOrNull();
  }

  Future<void> upsertItem(LocalShoppingItemsCompanion item) {
    return into(localShoppingItems).insertOnConflictUpdate(item);
  }

  Future<void> updateItemFields(
    String localId, {
    required String information,
    required String? quantity,
    required LocalSyncStatus syncStatus,
  }) {
    return (update(localShoppingItems)..where((t) => t.localId.equals(localId)))
        .write(LocalShoppingItemsCompanion(
      information: Value(information),
      quantity: Value(quantity),
      syncStatus: Value(syncStatus.dbValue),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateSyncStatus(
    String localId,
    LocalSyncStatus status, {
    String? remoteId,
  }) {
    return (update(localShoppingItems)..where((t) => t.localId.equals(localId)))
        .write(LocalShoppingItemsCompanion(
      syncStatus: Value(status.dbValue),
      remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
    ));
  }

  Future<void> markAsDeleted(String localId) {
    return (update(localShoppingItems)..where((t) => t.localId.equals(localId)))
        .write(LocalShoppingItemsCompanion(
      syncStatus: Value(LocalSyncStatus.pendingDelete.dbValue),
    ));
  }

  Future<void> hardDeleteItem(String localId) {
    return (delete(localShoppingItems)..where((t) => t.localId.equals(localId)))
        .go();
  }

  Future<List<LocalShoppingItem>> getSyncedItemsByGroup(String groupId) {
    return (select(localShoppingItems)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) => t.syncStatus.equals(LocalSyncStatus.synced.dbValue)))
        .get();
  }

  // Wird beim initialen Pull genutzt – ersetzt alle synced Items
  // Pending Items werden bewusst nicht angefasst
  Future<void> replaceAllSynced(
    String groupId,
    List<LocalShoppingItemsCompanion> items,
  ) async {
    await transaction(() async {
      await (delete(localShoppingItems)
            ..where((t) => t.groupId.equals(groupId))
            ..where(
                (t) => t.syncStatus.equals(LocalSyncStatus.synced.dbValue)))
          .go();

      await batch((b) {
        b.insertAll(localShoppingItems, items);
      });
    });
  }
}
