import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/shopping_item_dao.dart';
import 'package:meal_planner/data/repositories/supabase_shopping_list_repository.dart';
import 'package:meal_planner/data/sync/sync_adapter.dart';
import 'package:meal_planner/data/sync/sync_types.dart';

/// Bridges [SyncEngine] to the Supabase `shopping_list_items` table and the
/// local Drift `LocalShoppingItems` table.
///
/// Pull strategy: full list per call (the table is small and remote deletes
/// must propagate; see [MealPlanSyncAdapter] for the same reasoning). The
/// `since` argument from the engine is intentionally ignored.
class ShoppingListSyncAdapter implements SyncAdapter {
  ShoppingListSyncAdapter({
    required ShoppingItemDao dao,
    required SupabaseShoppingListRepository remote,
    required String groupId,
  })  : _dao = dao,
        _remote = remote,
        _groupId = groupId;

  final ShoppingItemDao _dao;
  final SupabaseShoppingListRepository _remote;
  final String _groupId;

  /// Set when `pullSince` runs so `applyRemote` knows there is a fresh pull
  /// to commit. Engine guarantees no concurrent runs for the same scope.
  bool _hasPendingPull = false;

  @visibleForTesting
  // ignore: use_setters_to_change_properties
  void debugSetHasPendingPull(bool value) => _hasPendingPull = value;

  @override
  String get featureKey => 'shopping_list';

  @override
  Future<List<PendingChange>> readPending() async {
    final rows = await _dao.getPendingItems(_groupId);
    return rows.map(_rowToPendingChange).toList();
  }

  @override
  Future<Set<String>> localPendingIds() => _dao.getPendingRemoteIds(_groupId);

  @override
  Future<void> markSynced(String id) async {
    final row = await _dao.getItemByLocalId(id);
    if (row == null) return;
    if (row.syncStatus == 'pendingDelete') {
      await _dao.hardDeleteItem(id);
    } else {
      await _dao.updateSyncStatus(id, 'synced');
    }
  }

  @override
  Future<void> markFailed(String id, Object error) =>
      _dao.updateSyncStatus(id, 'failed');

  @override
  Future<void> pushOne(PendingChange change) async {
    final row = await _dao.getItemByLocalId(change.id);
    if (row == null) return;

    switch (row.syncStatus) {
      case 'pendingCreate':
        final created = await _remote.addItem(row.information, row.quantity);
        // Toggle state if the local row was already checked before its first
        // sync (otherwise the freshly-inserted row would lose the check).
        if (row.isChecked) {
          await _remote.toggleItem(created.id, true);
        }
        await _dao.updateSyncStatus(change.id, 'synced',
            remoteId: created.id);

      case 'pendingUpdate':
      case 'failed':
        if (row.remoteId == null) {
          // Edge case: pendingUpdate without a remoteId — fall back to insert.
          final created =
              await _remote.addItem(row.information, row.quantity);
          if (row.isChecked) {
            await _remote.toggleItem(created.id, true);
          }
          await _dao.updateSyncStatus(change.id, 'synced',
              remoteId: created.id);
          return;
        }
        await _remote.updateItem(row.remoteId!, row.information, row.quantity);
        await _remote.toggleItem(row.remoteId!, row.isChecked);

      case 'pendingDelete':
        if (row.remoteId != null) {
          await _remote.removeItem(row.remoteId!);
        }
    }
  }

  @override
  Future<List<RemoteRow>> pullSince(DateTime? since, SyncScope scope) async {
    if (scope is! FullScope) {
      throw ArgumentError(
          'ShoppingListSyncAdapter requires a FullScope, got ${scope.runtimeType}');
    }
    final remoteItems = await _remote.getItems();
    _hasPendingPull = true;
    return remoteItems
        .map((item) => RemoteRow(
              id: item.id,
              updatedAt: DateTime.now(),
              deleted: false,
              data: {
                'id': item.id,
                'information': item.information,
                'quantity': item.quantity,
                'is_checked': item.isChecked,
              },
            ))
        .toList();
  }

  @override
  Future<void> applyRemote(List<RemoteRow> rows) async {
    if (!_hasPendingPull) return;
    _hasPendingPull = false;

    final existing = await _dao.getSyncedItemsByGroup(_groupId);
    final remoteIdToLocalId = {
      for (final item in existing)
        if (item.remoteId != null) item.remoteId!: item.localId,
    };

    final companions = rows
        .map((r) => LocalShoppingItemsCompanion(
              localId: Value(remoteIdToLocalId[r.id] ?? r.id),
              remoteId: Value(r.id),
              groupId: Value(_groupId),
              information: Value(r.data['information'] as String),
              quantity: Value(r.data['quantity'] as String?),
              isChecked: Value(r.data['is_checked'] as bool? ?? false),
              syncStatus: const Value('synced'),
              updatedAt: Value(DateTime.now()),
            ))
        .toList();

    await _dao.replaceAllSynced(_groupId, companions);
  }

  PendingChange _rowToPendingChange(LocalShoppingItem row) {
    final isDelete = row.syncStatus == 'pendingDelete';
    return PendingChange(
      id: row.localId,
      status: isDelete ? SyncItemStatus.pendingDelete : SyncItemStatus.pending,
      retryCount: 0,
      payload: const {},
    );
  }
}
