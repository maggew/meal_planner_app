import 'package:drift/drift.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/tables/local_shopping_items_table.dart';
import 'package:meal_planner/data/sync/local_sync_status.dart';
import 'package:meal_planner/data/sync/shopping_list_local_store.dart';

part 'shopping_item_dao.g.dart';

@DriftAccessor(tables: [LocalShoppingItems])
class ShoppingItemDao extends DatabaseAccessor<AppDatabase>
    with _$ShoppingItemDaoMixin
    implements ShoppingListLocalStore {
  ShoppingItemDao(super.db);

  ShoppingListRow _toRow(LocalShoppingItem r) => ShoppingListRow(
        localId: r.localId,
        syncStatus: LocalSyncStatus.fromDb(r.syncStatus),
        remoteId: r.remoteId,
        information: r.information,
        quantity: r.quantity,
        isChecked: r.isChecked,
      );

  // UI nutzt diesen Stream – reagiert automatisch auf Änderungen
  Stream<List<LocalShoppingItem>> watchItemsByGroup(String groupId) {
    return (select(localShoppingItems)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) =>
              t.syncStatus.equals(LocalSyncStatus.pendingDelete.dbValue).not()))
        .watch();
  }

  // Für den Sync-Service – via ShoppingListLocalStore
  @override
  Future<List<ShoppingListRow>> getPendingItems(String groupId) async {
    final rows = await (select(localShoppingItems)
          ..where((t) => t.groupId.equals(groupId))
          ..where(
              (t) => t.syncStatus.equals(LocalSyncStatus.synced.dbValue).not()))
        .get();
    return rows.map(_toRow).toList();
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

  @override
  Future<ShoppingListRow?> getItemByLocalId(String localId) async {
    final row = await (select(localShoppingItems)
          ..where((t) => t.localId.equals(localId)))
        .getSingleOrNull();
    return row == null ? null : _toRow(row);
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

  @override
  Future<List<ShoppingListRow>> getSyncedItemsByGroup(String groupId) async {
    final rows = await (select(localShoppingItems)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) => t.syncStatus.equals(LocalSyncStatus.synced.dbValue)))
        .get();
    return rows.map(_toRow).toList();
  }

  // Wird beim initialen Pull genutzt – ersetzt alle synced Items via ShoppingListLocalStore
  // Pending Items werden bewusst nicht angefasst
  @override
  Future<void> replaceAllSynced(
    String groupId,
    List<ShoppingListSyncedRow> rows,
  ) async {
    final companions = rows
        .map((r) => LocalShoppingItemsCompanion(
              localId: Value(r.localId),
              remoteId: Value(r.remoteId),
              groupId: Value(groupId),
              information: Value(r.information),
              quantity: Value(r.quantity),
              isChecked: Value(r.isChecked),
              syncStatus: Value(LocalSyncStatus.synced.dbValue),
              updatedAt: Value(DateTime.now()),
            ))
        .toList();

    await transaction(() async {
      await (delete(localShoppingItems)
            ..where((t) => t.groupId.equals(groupId))
            ..where(
                (t) => t.syncStatus.equals(LocalSyncStatus.synced.dbValue)))
          .go();

      await batch((b) {
        b.insertAll(localShoppingItems, companions);
      });
    });
  }
}
