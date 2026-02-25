import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/meal_plan_dao.dart';
import 'package:meal_planner/data/model/meal_plan_entry_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealPlanSyncService {
  final MealPlanDao _dao;
  final SupabaseClient _supabase;
  final String _groupId;

  MealPlanSyncService({
    required MealPlanDao dao,
    required SupabaseClient supabase,
    required String groupId,
  })  : _dao = dao,
        _supabase = supabase,
        _groupId = groupId;

  Future<void> syncPending() async {
    final pending = await _dao.getPendingEntries(_groupId);

    for (final entry in pending) {
      try {
        switch (entry.syncStatus) {
          case 'pendingCreate':
            final response = await _supabase
                .from(SupabaseConstants.mealPlanEntriesTable)
                .insert({
                  SupabaseConstants.mealPlanEntryGroupId: _groupId,
                  SupabaseConstants.mealPlanEntryRecipeId: entry.recipeId,
                  SupabaseConstants.mealPlanEntryDate: entry.date,
                  SupabaseConstants.mealPlanEntryMealType: entry.mealType,
                  SupabaseConstants.mealPlanEntryUpdatedAt:
                      entry.updatedAt.toIso8601String(),
                })
                .select()
                .single();
            final remoteId =
                response[SupabaseConstants.mealPlanEntryId] as String;
            await _dao.updateSyncStatus(entry.localId, 'synced',
                remoteId: remoteId);

          case 'pendingUpdate':
            if (entry.remoteId != null) {
              await _supabase
                  .from(SupabaseConstants.mealPlanEntriesTable)
                  .update({SupabaseConstants.mealPlanEntryCookId: entry.cookId})
                  .eq(SupabaseConstants.mealPlanEntryId, entry.remoteId!);
              await _dao.updateSyncStatus(entry.localId, 'synced',
                  remoteId: entry.remoteId);
            }

          case 'pendingDelete':
            if (entry.remoteId != null) {
              await _supabase
                  .from(SupabaseConstants.mealPlanEntriesTable)
                  .delete()
                  .eq(SupabaseConstants.mealPlanEntryId, entry.remoteId!);
            }
            await _dao.hardDeleteEntry(entry.localId);
        }
      } catch (e) {
        debugPrint('[MealPlanSync] Fehler bei ${entry.localId}: $e');
        continue;
      }
    }
  }

  Future<void> pullRemoteForMonth(int year, int month) async {
    try {
      final yearMonth =
          '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

      final response = await _supabase
          .from(SupabaseConstants.mealPlanEntriesTable)
          .select()
          .eq(SupabaseConstants.mealPlanEntryGroupId, _groupId)
          .gte(SupabaseConstants.mealPlanEntryDate, '$yearMonth-01')
          .lte(SupabaseConstants.mealPlanEntryDate, '$yearMonth-31');

      final companions = (response as List)
          .cast<Map<String, dynamic>>()
          .map((data) {
            final model = MealPlanEntryModel.fromSupabase(data);
            return LocalMealPlanEntriesCompanion(
              localId: Value(model.id),
              remoteId: Value(model.id),
              groupId: Value(_groupId),
              recipeId: Value(model.recipeId),
              date: Value(model.date),
              mealType: Value(model.mealType),
              cookId: Value(model.cookId),
              syncStatus: const Value('synced'),
              updatedAt: Value(DateTime.now()),
            );
          })
          .toList();

      await _dao.replaceAllSynced(_groupId, yearMonth, companions);
    } catch (_) {
      // Pull fehlgeschlagen – lokale Daten bleiben erhalten
    }
  }

  Future<void> sync(int year, int month) async {
    await syncPending();
    await pullRemoteForMonth(year, month);
  }
}
