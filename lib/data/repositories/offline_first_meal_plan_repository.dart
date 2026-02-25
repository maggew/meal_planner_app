import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/meal_plan_dao.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/domain/repositories/meal_plan_repository.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class OfflineFirstMealPlanRepository implements MealPlanRepository {
  final MealPlanDao _dao;
  final SupabaseClient _supabase;
  final String _groupId;
  final Ref _ref;
  final _uuid = const Uuid();

  OfflineFirstMealPlanRepository({
    required MealPlanDao dao,
    required SupabaseClient supabase,
    required String groupId,
    required Ref ref,
  })  : _dao = dao,
        _supabase = supabase,
        _groupId = groupId,
        _ref = ref;

  bool get _isOnline => _ref.read(isOnlineProvider);

  @override
  Stream<List<MealPlanEntry>> watchEntriesForDate(DateTime date) {
    return _dao
        .watchEntriesForDate(_groupId, _dateToString(date))
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<void> addEntry({
    required DateTime date,
    required MealType mealType,
    required String recipeId,
  }) async {
    final localId = _uuid.v4();
    final dateStr = _dateToString(date);
    final now = DateTime.now();

    await _dao.upsertEntry(LocalMealPlanEntriesCompanion(
      localId: Value(localId),
      groupId: Value(_groupId),
      recipeId: Value(recipeId),
      date: Value(dateStr),
      mealType: Value(mealType.value),
      syncStatus: const Value('pendingCreate'),
      updatedAt: Value(now),
    ));

    if (_isOnline) {
      try {
        final response = await _supabase
            .from(SupabaseConstants.mealPlanEntriesTable)
            .insert({
              SupabaseConstants.mealPlanEntryGroupId: _groupId,
              SupabaseConstants.mealPlanEntryRecipeId: recipeId,
              SupabaseConstants.mealPlanEntryDate: dateStr,
              SupabaseConstants.mealPlanEntryMealType: mealType.value,
              SupabaseConstants.mealPlanEntryCookId: null,
              SupabaseConstants.mealPlanEntryUpdatedAt: now.toIso8601String(),
            })
            .select()
            .single();

        final remoteId =
            response[SupabaseConstants.mealPlanEntryId] as String;
        await _dao.updateSyncStatus(localId, 'synced', remoteId: remoteId);
      } catch (e) {
        debugPrint('[MealPlan] Supabase insert fehlgeschlagen: $e');
        // bleibt pendingCreate – SyncService holt es nach
      }
    }
  }

  @override
  Future<void> setCook(String localId, String? cookId) async {
    await _dao.updateCookId(localId, cookId);

    final entry = await _dao.getEntryByLocalId(localId);
    if (entry == null || entry.remoteId == null) return;

    if (_isOnline) {
      try {
        await _supabase
            .from(SupabaseConstants.mealPlanEntriesTable)
            .update({SupabaseConstants.mealPlanEntryCookId: cookId})
            .eq(SupabaseConstants.mealPlanEntryId, entry.remoteId!);
        await _dao.updateSyncStatus(localId, 'synced',
            remoteId: entry.remoteId);
      } catch (e) {
        debugPrint('[MealPlan] setCook Supabase fehlgeschlagen: $e');
      }
    }
  }

  @override
  Future<void> removeEntry(String localId) async {
    final entry = await _dao.getEntryByLocalId(localId);
    if (entry == null) return;

    await _dao.markAsDeleted(localId);

    if (_isOnline && entry.remoteId != null) {
      try {
        await _supabase
            .from(SupabaseConstants.mealPlanEntriesTable)
            .delete()
            .eq(SupabaseConstants.mealPlanEntryId, entry.remoteId!);
        await _dao.hardDeleteEntry(localId);
      } catch (_) {
        // bleibt pendingDelete
      }
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  MealPlanEntry _toEntity(LocalMealPlanEntry row) {
    final parts = row.date.split('-');
    return MealPlanEntry(
      id: row.localId,
      remoteId: row.remoteId,
      groupId: row.groupId,
      recipeId: row.recipeId,
      date: DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      ),
      mealType: MealType.fromValue(row.mealType),
      cookId: row.cookId,
    );
  }

  static String _dateToString(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
