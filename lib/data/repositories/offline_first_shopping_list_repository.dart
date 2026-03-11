import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/shopping_item_dao.dart';
import 'package:meal_planner/data/repositories/supabase_shopping_list_repository.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:meal_planner/domain/repositories/shopping_list_repository.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:uuid/uuid.dart';

class OfflineFirstShoppingListRepository implements ShoppingListRepository {
  final ShoppingItemDao _dao;
  final SupabaseShoppingListRepository _remote;
  final String _groupId;
  final Ref _ref;
  final _uuid = const Uuid();

  OfflineFirstShoppingListRepository({
    required ShoppingItemDao dao,
    required SupabaseShoppingListRepository remote,
    required String groupId,
    required Ref ref,
  })  : _dao = dao,
        _remote = remote,
        _ref = ref,
        _groupId = groupId;

  bool get _isOnline => _ref.read(isOnlineProvider);

  @override
  Stream<List<ShoppingListItem>> watchItems() {
    return _dao.watchItemsByGroup(_groupId).map((items) => items
        .map((item) => ShoppingListItem(
              id: item.remoteId ?? item.localId,
              groupId: item.groupId,
              information: item.information,
              quantity: item.quantity,
              isChecked: item.isChecked,
            ))
        .toList());
  }

  @override
  Future<List<ShoppingListItem>> getItems() async {
    final items = await _dao.watchItemsByGroup(_groupId).first;
    return items
        .map((item) => ShoppingListItem(
              id: item.remoteId ?? item.localId,
              groupId: item.groupId,
              information: item.information,
              quantity: item.quantity,
              isChecked: item.isChecked,
            ))
        .toList();
  }

  @override
  Future<ShoppingListItem> addItem(String information, String? quantity) async {
    final localId = _uuid.v4();
    final now = DateTime.now();

    await _dao.upsertItem(LocalShoppingItemsCompanion(
      localId: Value(localId),
      groupId: Value(_groupId),
      information: Value(information),
      quantity: Value(quantity),
      isChecked: const Value(false),
      syncStatus: const Value('pendingCreate'),
      updatedAt: Value(now),
    ));

    if (await _isOnline) {
      try {
        final created = await _remote.addItem(information, quantity);
        await _dao.updateSyncStatus(localId, 'synced', remoteId: created.id);
        return created;
      } catch (_) {
        // bleibt pending, Sync-Service holt es nach
      }
    }

    return ShoppingListItem(
      id: localId,
      groupId: _groupId,
      information: information,
      quantity: quantity,
      isChecked: false,
    );
  }

  @override
  Future<void> updateItem(String itemId, String information, String? quantity) async {
    await _updateLocalInfoByAnyId(itemId, information: information, quantity: quantity);

    if (await _isOnline) {
      try {
        await _remote.updateItem(itemId, information, quantity);
        await _markSyncedByRemoteId(itemId);
      } catch (_) {
        // bleibt pendingUpdate
      }
    }
  }

  @override
  Future<void> toggleItem(String itemId, bool isChecked) async {
    // itemId kann localId oder remoteId sein – wir suchen beides
    await _updateLocalByAnyId(itemId, isChecked: isChecked);

    if (await _isOnline) {
      try {
        await _remote.toggleItem(itemId, isChecked);
        await _markSyncedByRemoteId(itemId);
      } catch (_) {
        // bleibt pendingUpdate
      }
    }
  }

  @override
  Future<void> removeItem(String itemId) async {
    await _markDeletedByAnyId(itemId);

    if (await _isOnline) {
      try {
        await _remote.removeItem(itemId);
        await _dao.hardDeleteItem(itemId);
      } catch (_) {
        // bleibt pendingDelete
      }
    }
  }

  @override
  Future<void> removeCheckedItems() async {
    final items = await _dao.watchItemsByGroup(_groupId).first;
    final checkedItems = items.where((i) => i.isChecked).toList();
    if (checkedItems.isEmpty) return;

    for (final item in checkedItems) {
      await _dao.markAsDeleted(item.localId);
    }

    if (await _isOnline) {
      try {
        await _remote.removeCheckedItems();
        for (final item in checkedItems) {
          await _dao.hardDeleteItem(item.localId);
        }
      } catch (_) {
        // bleibt pendingDelete
      }
    }
  }

  // Hilfsmethoden – suchen nach localId oder remoteId
  Future<void> _updateLocalInfoByAnyId(String id, {required String information, String? quantity}) async {
    final items = await _dao.watchItemsByGroup(_groupId).first;
    final item = items.firstWhere(
      (i) => i.localId == id || i.remoteId == id,
      orElse: () => throw Exception('Item nicht gefunden: $id'),
    );
    // pendingCreate beibehalten: Item noch nie synced, wird beim nächsten Sync mit den
    // aktuellen Daten erstellt – kein Überschreiben auf pendingUpdate nötig
    final newStatus = item.syncStatus == 'pendingCreate' ? 'pendingCreate' : 'pendingUpdate';
    await _dao.upsertItem(LocalShoppingItemsCompanion(
      localId: Value(item.localId),
      groupId: Value(item.groupId),
      information: Value(information),
      quantity: Value(quantity),
      isChecked: Value(item.isChecked),
      syncStatus: Value(newStatus),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> _updateLocalByAnyId(String id, {required bool isChecked}) async {
    final items = await _dao.watchItemsByGroup(_groupId).first;
    final item = items.firstWhere(
      (i) => i.localId == id || i.remoteId == id,
      orElse: () => throw Exception('Item nicht gefunden: $id'),
    );
    // pendingCreate beibehalten: Item noch nie synced, wird beim nächsten Sync mit den
    // aktuellen Daten erstellt – kein Überschreiben auf pendingUpdate nötig
    final newStatus = item.syncStatus == 'pendingCreate' ? 'pendingCreate' : 'pendingUpdate';
    await _dao.upsertItem(LocalShoppingItemsCompanion(
      localId: Value(item.localId),
      groupId: Value(item.groupId),
      information: Value(item.information),
      quantity: Value(item.quantity),
      isChecked: Value(isChecked),
      syncStatus: Value(newStatus),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> _markDeletedByAnyId(String id) async {
    final items = await _dao.watchItemsByGroup(_groupId).first;
    final item = items.firstWhere(
      (i) => i.localId == id || i.remoteId == id,
      orElse: () => throw Exception('Item nicht gefunden: $id'),
    );
    await _dao.markAsDeleted(item.localId);
  }

  Future<void> _markSyncedByRemoteId(String remoteId) async {
    final items = await _dao.watchItemsByGroup(_groupId).first;
    final item = items.firstWhere(
      (i) => i.remoteId == remoteId,
      orElse: () => throw Exception('Item nicht gefunden: $remoteId'),
    );
    await _dao.updateSyncStatus(item.localId, 'synced');
  }
}
