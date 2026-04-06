import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/shopping_item_dao.dart';
import 'package:meal_planner/data/repositories/supabase_shopping_list_repository.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:meal_planner/domain/repositories/shopping_list_repository.dart';
import 'package:uuid/uuid.dart';

class OfflineFirstShoppingListRepository implements ShoppingListRepository {
  final ShoppingItemDao _dao;
  final SupabaseShoppingListRepository _remote;
  final String _groupId;
  final _uuid = const Uuid();

  Timer? _timer;
  bool _isSyncing = false;

  OfflineFirstShoppingListRepository({
    required ShoppingItemDao dao,
    required SupabaseShoppingListRepository remote,
    required String groupId,
  })  : _dao = dao,
        _remote = remote,
        _groupId = groupId;

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
  }

  @override
  Future<void> toggleItem(String itemId, bool isChecked) async {
    // itemId kann localId oder remoteId sein – wir suchen beides
    await _updateLocalByAnyId(itemId, isChecked: isChecked);
  }

  @override
  Future<void> removeItem(String itemId) async {
    await _markDeletedByAnyId(itemId);
  }

  @override
  Future<void> removeCheckedItems() async {
    final items = await _dao.watchItemsByGroup(_groupId).first;
    final checkedItems = items.where((i) => i.isChecked).toList();
    if (checkedItems.isEmpty) return;

    for (final item in checkedItems) {
      await _dao.markAsDeleted(item.localId);
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
    await _dao.updateItemFields(
      item.localId,
      information: information,
      quantity: quantity,
      syncStatus: newStatus,
    );
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

  // ── Sync ───────────────────────────────────────────────────────────────────

  void startPeriodicSync() {
    if (_timer?.isActive ?? false) return;
    sync();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => sync());
  }

  void stopPeriodicSync() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await syncPendingItems();
      await pullRemoteItems();
    } finally {
      _isSyncing = false;
    }
  }

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
            if (item.remoteId == null) {
              final created = await _remote.addItem(item.information, item.quantity);
              await _dao.updateSyncStatus(item.localId, 'synced', remoteId: created.id);
              break;
            }
            await _remote.updateItem(item.remoteId!, item.information, item.quantity);
            await _remote.toggleItem(item.remoteId!, item.isChecked);
            await _dao.updateSyncStatus(item.localId, 'synced');

          case 'pendingDelete':
            if (item.remoteId != null) {
              await _remote.removeItem(item.remoteId!);
            }
            await _dao.hardDeleteItem(item.localId);
        }
      } catch (e) {
        debugPrint('Shopping-Sync fehlgeschlagen für Item ${item.localId}: $e');
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
      debugPrint('Shopping-Pull fehlgeschlagen: $e');
    }
  }
}
