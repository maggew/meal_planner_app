import 'package:drift/drift.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/tables/local_shopping_items_table.dart';

part 'shopping_item_dao.g.dart';

@DriftAccessor(tables: [LocalShoppingItems])
class ShoppingItemDao extends DatabaseAccessor<AppDatabase>
    with _$ShoppingItemDaoMixin {
  ShoppingItemDao(super.db);

  // UI nutzt diesen Stream – reagiert automatisch auf Änderungen
  Stream<List<LocalShoppingItem>> watchItemsByGroup(String groupId) {
    return (select(localShoppingItems)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) => t.syncStatus.equals('pendingDelete').not()))
        .watch();
  }

  // Für den Sync-Service
  Future<List<LocalShoppingItem>> getPendingItems(String groupId) {
    return (select(localShoppingItems)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) => t.syncStatus.equals('synced').not()))
        .get();
  }

  Future<void> upsertItem(LocalShoppingItemsCompanion item) {
    return into(localShoppingItems).insertOnConflictUpdate(item);
  }

  Future<void> updateSyncStatus(
    String localId,
    String status, {
    String? remoteId,
  }) {
    return (update(localShoppingItems)..where((t) => t.localId.equals(localId)))
        .write(LocalShoppingItemsCompanion(
      syncStatus: Value(status),
      remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
    ));
  }

  Future<void> markAsDeleted(String localId) {
    return (update(localShoppingItems)..where((t) => t.localId.equals(localId)))
        .write(const LocalShoppingItemsCompanion(
      syncStatus: Value('pendingDelete'),
    ));
  }

  Future<void> hardDeleteItem(String localId) {
    return (delete(localShoppingItems)..where((t) => t.localId.equals(localId)))
        .go();
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
            ..where((t) => t.syncStatus.equals('synced')))
          .go();

      await batch((b) {
        b.insertAll(localShoppingItems, items);
      });
    });
  }
}
