import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/shopping_item_dao.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShoppingListRealtimeService {
  final SupabaseClient _supabase;
  final ShoppingItemDao _dao;
  final String _groupId;

  RealtimeChannel? _channel;

  ShoppingListRealtimeService({
    required SupabaseClient supabase,
    required ShoppingItemDao dao,
    required String groupId,
  })  : _supabase = supabase,
        _dao = dao,
        _groupId = groupId;

  void subscribe() async {
    _channel = _supabase
        .channel('shopping_list_$_groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseConstants.shoppingListItemsTable,
          callback: (payload) {
            if (payload.eventType == PostgresChangeEvent.delete) {
              _onDelete(payload.oldRecord);
              return;
            }

            final record = payload.newRecord;
            final eventGroupId =
                record[SupabaseConstants.shoppingListItemGroupId] as String?;
            if (eventGroupId != _groupId) return; // manueller Filter

            switch (payload.eventType) {
              case PostgresChangeEvent.insert:
                _onInsert(payload.newRecord);
                break;
              case PostgresChangeEvent.update:
                _onUpdate(payload.newRecord);
                break;
              case PostgresChangeEvent.delete:
                _onDelete(payload.oldRecord);
                break;
              default:
                break;
            }
          },
        )
        .subscribe();
  }

  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  Future<void> _onInsert(Map<String, dynamic> record) async {
    final remoteId = record[SupabaseConstants.shoppingListItemId] as String;

    // Prüfen ob wir das Item bereits lokal haben (eigene Änderung)
    final existing = await _dao.watchItemsByGroup(_groupId).first;
    final alreadyExists = existing.any((i) => i.remoteId == remoteId);
    if (alreadyExists) return;

    await _dao.upsertItem(LocalShoppingItemsCompanion(
      localId: Value(remoteId),
      remoteId: Value(remoteId),
      groupId: Value(_groupId),
      information: Value(
          record[SupabaseConstants.shoppingListItemInformation] as String),
      quantity:
          Value(record[SupabaseConstants.shoppingListItemQuantity] as String?),
      isChecked: Value(
          record[SupabaseConstants.shoppingListItemIsChecked] as bool? ??
              false),
      syncStatus: const Value('synced'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> _onUpdate(Map<String, dynamic> record) async {
    final remoteId = record[SupabaseConstants.shoppingListItemId] as String?;
    if (remoteId == null) return;

    final existing = await _dao.watchItemsByGroup(_groupId).first;
    final localItem = existing.where((i) => i.remoteId == remoteId).firstOrNull;
    if (localItem == null || localItem.syncStatus != 'synced') return;

    await _dao.upsertItem(LocalShoppingItemsCompanion(
      localId: Value(localItem.localId),
      remoteId: Value(remoteId),
      groupId: Value(_groupId),
      information: Value(
          record[SupabaseConstants.shoppingListItemInformation] as String),
      quantity:
          Value(record[SupabaseConstants.shoppingListItemQuantity] as String?),
      isChecked: Value(
          record[SupabaseConstants.shoppingListItemIsChecked] as bool? ??
              false),
      syncStatus: const Value('synced'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> _onDelete(Map<String, dynamic> record) async {
    final remoteId = record[SupabaseConstants.shoppingListItemId] as String?;
    if (remoteId == null) return;

    final existing = await _dao.watchItemsByGroup(_groupId).first;
    final localItem = existing.where((i) => i.remoteId == remoteId).firstOrNull;
    if (localItem == null || localItem.syncStatus != 'synced') return;

    await _dao.hardDeleteItem(localItem.localId);
  }
}
