import 'package:meal_planner/data/sync/local_sync_status.dart';

/// A locally-stored shopping list item exposed to the sync adapter.
///
/// Uses plain Dart types — no Drift `Value<>` wrappers or generated row
/// classes — so the adapter can be tested without spinning up Drift.
class ShoppingListRow {
  const ShoppingListRow({
    required this.localId,
    required this.syncStatus,
    this.remoteId,
    required this.information,
    this.quantity,
    required this.isChecked,
  });

  final String localId;
  final LocalSyncStatus syncStatus;
  final String? remoteId;
  final String information;
  final String? quantity;
  final bool isChecked;
}

/// A remote row to be written into local storage after a pull.
///
/// syncStatus is always [LocalSyncStatus.synced] — the DAO sets it
/// implicitly when calling [ShoppingListLocalStore.replaceAllSynced].
class ShoppingListSyncedRow {
  const ShoppingListSyncedRow({
    required this.localId,
    required this.remoteId,
    required this.information,
    this.quantity,
    required this.isChecked,
  });

  final String localId;
  final String remoteId;
  final String information;
  final String? quantity;
  final bool isChecked;
}

/// Narrow DAO contract required by [ShoppingListSyncAdapter].
///
/// Speaks only plain Dart and [LocalSyncStatus] — no Drift types.
/// [ShoppingItemDao] implements this; tests can supply a lightweight fake.
abstract class ShoppingListLocalStore {
  /// All non-synced items for [groupId].
  Future<List<ShoppingListRow>> getPendingItems(String groupId);

  /// Remote IDs of items that are locally pending (local-pending-wins).
  Future<Set<String>> getPendingRemoteIds(String groupId);

  /// Single item by local UUID, or null if concurrently deleted.
  Future<ShoppingListRow?> getItemByLocalId(String localId);

  Future<void> updateSyncStatus(
    String localId,
    LocalSyncStatus status, {
    String? remoteId,
  });

  Future<void> hardDeleteItem(String localId);

  /// All synced items for [groupId]. Used to preserve existing localIds
  /// during a full-list pull.
  Future<List<ShoppingListRow>> getSyncedItemsByGroup(String groupId);

  /// Atomically replaces all synced items for [groupId] with [rows].
  /// Pending items are never touched.
  Future<void> replaceAllSynced(String groupId, List<ShoppingListSyncedRow> rows);
}
