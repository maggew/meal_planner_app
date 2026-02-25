import 'package:drift/drift.dart';
import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/meal_plan_dao.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealPlanRealtimeService {
  final SupabaseClient _supabase;
  final MealPlanDao _dao;
  final String _groupId;

  RealtimeChannel? _channel;

  MealPlanRealtimeService({
    required SupabaseClient supabase,
    required MealPlanDao dao,
    required String groupId,
  })  : _supabase = supabase,
        _dao = dao,
        _groupId = groupId;

  void subscribe() {
    _channel = _supabase
        .channel('meal_plan_$_groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseConstants.mealPlanEntriesTable,
          callback: (payload) {
            if (payload.eventType == PostgresChangeEvent.delete) {
              _onDelete(payload.oldRecord);
              return;
            }

            final record = payload.newRecord;
            final eventGroupId =
                record[SupabaseConstants.mealPlanEntryGroupId] as String?;
            if (eventGroupId != _groupId) return;

            switch (payload.eventType) {
              case PostgresChangeEvent.insert:
                _onInsert(record);
              case PostgresChangeEvent.update:
                _onUpdate(record);
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
    final remoteId =
        record[SupabaseConstants.mealPlanEntryId] as String;
    final date = record[SupabaseConstants.mealPlanEntryDate] as String;
    final yearMonth = date.substring(0, 7);

    // Skip if we already have this entry (our own write)
    final existing = await _dao.watchEntriesForMonth(_groupId, yearMonth).first;
    if (existing.any((e) => e.remoteId == remoteId)) return;

    await _dao.upsertEntry(LocalMealPlanEntriesCompanion(
      localId: Value(remoteId),
      remoteId: Value(remoteId),
      groupId: Value(_groupId),
      recipeId:
          Value(record[SupabaseConstants.mealPlanEntryRecipeId] as String),
      date: Value(date),
      mealType:
          Value(record[SupabaseConstants.mealPlanEntryMealType] as String),
      syncStatus: const Value('synced'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> _onUpdate(Map<String, dynamic> record) async {
    final remoteId =
        record[SupabaseConstants.mealPlanEntryId] as String?;
    if (remoteId == null) return;

    final date = record[SupabaseConstants.mealPlanEntryDate] as String;
    final yearMonth = date.substring(0, 7);

    final existing = await _dao.watchEntriesForMonth(_groupId, yearMonth).first;
    final localEntry =
        existing.where((e) => e.remoteId == remoteId).firstOrNull;
    if (localEntry == null || localEntry.syncStatus != 'synced') return;

    await _dao.upsertEntry(LocalMealPlanEntriesCompanion(
      localId: Value(localEntry.localId),
      remoteId: Value(remoteId),
      groupId: Value(_groupId),
      recipeId:
          Value(record[SupabaseConstants.mealPlanEntryRecipeId] as String),
      date: Value(date),
      mealType:
          Value(record[SupabaseConstants.mealPlanEntryMealType] as String),
      syncStatus: const Value('synced'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> _onDelete(Map<String, dynamic> record) async {
    final remoteId =
        record[SupabaseConstants.mealPlanEntryId] as String?;
    if (remoteId == null) return;
    await _dao.hardDeleteByRemoteId(remoteId);
  }
}
