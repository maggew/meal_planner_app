import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/meal_plan_dao.dart';
import 'package:meal_planner/data/sync/local_sync_status.dart';
import 'package:meal_planner/data/sync/sync_adapter.dart';
import 'package:meal_planner/data/sync/sync_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bridges [SyncEngine] to the Supabase `meal_plan_entries` table and the
/// local Drift `LocalMealPlanEntries` table.
///
/// Pull strategy: full month per call. Drift's `replaceAllSynced` performs a
/// month-wipe-then-insert under the hood, which is how remote deletes by
/// other group members propagate (the remote table has no soft-delete
/// column, so a delta pull would never see them disappear). The `since`
/// argument from the engine is therefore intentionally ignored — the
/// `lastPulledAt` cursor is still maintained for observability and to keep
/// the engine contract uniform with adapters that *do* use deltas.
class MealPlanSyncAdapter implements SyncAdapter {
  MealPlanSyncAdapter({
    required MealPlanDao dao,
    required SupabaseClient supabase,
    required String groupId,
  })  : _dao = dao,
        _supabase = supabase,
        _groupId = groupId;

  final MealPlanDao _dao;
  final SupabaseClient _supabase;
  final String _groupId;

  /// `yyyy-MM` of the most recent pull, captured for use in `applyRemote`'s
  /// month-replace. Set by `pullSince` and read by `applyRemote` within the
  /// same engine run (engine guarantees no concurrent runs for the same
  /// scope).
  String? _pendingMonthKey;

  @visibleForTesting
  // ignore: use_setters_to_change_properties
  void debugSetPendingMonthKey(String? key) => _pendingMonthKey = key;

  @override
  String get featureKey => 'meal_plan';

  @override
  Future<List<PendingChange>> readPending() async {
    final rows = await _dao.getPendingEntries(_groupId);
    return rows.map(_rowToPendingChange).toList();
  }

  @override
  Future<Set<String>> localPendingIds() => _dao.getPendingRemoteIds(_groupId);

  @override
  Future<void> markSynced(String id) async {
    final row = await _dao.getEntryByLocalId(id);
    if (row == null) return;
    if (LocalSyncStatus.fromDb(row.syncStatus) == LocalSyncStatus.pendingDelete) {
      await _dao.hardDeleteEntry(id);
    } else {
      await _dao.updateSyncStatus(id, LocalSyncStatus.synced);
    }
  }

  @override
  Future<void> markFailed(String id, Object error) =>
      _dao.updateSyncStatus(id, LocalSyncStatus.failed);

  @override
  Future<void> pushOne(PendingChange change) async {
    final row = await _dao.getEntryByLocalId(change.id);
    if (row == null) return; // Concurrently deleted; treat as no-op success.

    switch (LocalSyncStatus.fromDb(row.syncStatus)) {
      case LocalSyncStatus.pendingCreate:
        final response = await _supabase
            .from(SupabaseConstants.mealPlanEntriesTable)
            .insert({
              SupabaseConstants.mealPlanEntryGroupId: _groupId,
              SupabaseConstants.mealPlanEntryRecipeId:
                  row.recipeId.isEmpty ? null : row.recipeId,
              SupabaseConstants.mealPlanEntryCustomName: row.customName,
              SupabaseConstants.mealPlanEntryDate: row.date,
              SupabaseConstants.mealPlanEntryMealType: row.mealType,
              SupabaseConstants.mealPlanEntryCookIds:
                  _decodeCookIds(row.cookIdsJson),
              SupabaseConstants.mealPlanEntryUpdatedAt:
                  row.updatedAt.toIso8601String(),
            })
            .select()
            .single();
        final remoteId =
            response[SupabaseConstants.mealPlanEntryId] as String;
        // Persist the new remoteId now; engine's subsequent markSynced is
        // an idempotent no-op (status -> synced again).
        await _dao.updateSyncStatus(change.id, LocalSyncStatus.synced,
            remoteId: remoteId);

      case LocalSyncStatus.pendingUpdate:
      case LocalSyncStatus.failed:
        if (row.remoteId == null) return;
        await _supabase
            .from(SupabaseConstants.mealPlanEntriesTable)
            .update(buildUpdatePayload(row))
            .eq(SupabaseConstants.mealPlanEntryId, row.remoteId!);

      case LocalSyncStatus.pendingDelete:
        if (row.remoteId != null) {
          await _supabase
              .from(SupabaseConstants.mealPlanEntriesTable)
              .delete()
              .eq(SupabaseConstants.mealPlanEntryId, row.remoteId!);
        }

      case LocalSyncStatus.synced:
        // Already synced — no push needed.
        break;
    }
  }

  @override
  Future<List<RemoteRow>> pullSince(DateTime? since, SyncScope scope) async {
    if (scope is! MonthScope) {
      throw ArgumentError(
          'MealPlanSyncAdapter requires a MonthScope, got ${scope.runtimeType}');
    }
    final yearMonth = scope.key; // 'yyyy-MM'
    _pendingMonthKey = yearMonth;

    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final nextMonth = DateTime(year, month + 1, 1);
    final nextMonthKey =
        '${nextMonth.year.toString().padLeft(4, '0')}-${nextMonth.month.toString().padLeft(2, '0')}';

    final response = await _supabase
        .from(SupabaseConstants.mealPlanEntriesTable)
        .select()
        .eq(SupabaseConstants.mealPlanEntryGroupId, _groupId)
        .gte(SupabaseConstants.mealPlanEntryDate, '$yearMonth-01')
        .lt(SupabaseConstants.mealPlanEntryDate, '$nextMonthKey-01');

    return (response as List).cast<Map<String, dynamic>>().map((data) {
      final id = data[SupabaseConstants.mealPlanEntryId] as String;
      final updatedAtRaw =
          data[SupabaseConstants.mealPlanEntryUpdatedAt] as String?;
      return RemoteRow(
        id: id,
        updatedAt: updatedAtRaw != null
            ? DateTime.parse(updatedAtRaw)
            : DateTime.fromMillisecondsSinceEpoch(0),
        deleted: false,
        data: data,
      );
    }).toList();
  }

  @override
  Future<void> applyRemote(List<RemoteRow> rows) async {
    final yearMonth = _pendingMonthKey;
    _pendingMonthKey = null;
    if (yearMonth == null) return;

    final companions = rows.map((r) {
      final data = r.data;
      final rawCookIds = data[SupabaseConstants.mealPlanEntryCookIds];
      final cookIds = rawCookIds is List
          ? rawCookIds.cast<String>()
          : const <String>[];
      return LocalMealPlanEntriesCompanion(
        localId: Value(r.id),
        remoteId: Value(r.id),
        groupId: Value(_groupId),
        recipeId: Value(
            (data[SupabaseConstants.mealPlanEntryRecipeId] as String?) ?? ''),
        customName:
            Value(data[SupabaseConstants.mealPlanEntryCustomName] as String?),
        date: Value(data[SupabaseConstants.mealPlanEntryDate] as String),
        mealType:
            Value(data[SupabaseConstants.mealPlanEntryMealType] as String),
        cookIdsJson:
            Value(cookIds.isEmpty ? null : jsonEncode(cookIds)),
        syncStatus: Value(LocalSyncStatus.synced.dbValue),
        updatedAt: Value(DateTime.now()),
      );
    }).toList();

    await _dao.replaceAllSynced(_groupId, yearMonth, companions);
  }

  /// Builds the Supabase update body for a pending-update row. Extracted so
  /// the exact shape can be unit-tested without mocking Supabase's fluent
  /// query API.
  @visibleForTesting
  static Map<String, dynamic> buildUpdatePayload(LocalMealPlanEntry row) {
    return {
      SupabaseConstants.mealPlanEntryRecipeId:
          row.recipeId.isEmpty ? null : row.recipeId,
      SupabaseConstants.mealPlanEntryCustomName: row.customName,
      SupabaseConstants.mealPlanEntryDate: row.date,
      SupabaseConstants.mealPlanEntryMealType: row.mealType,
      SupabaseConstants.mealPlanEntryCookIds: _decodeCookIds(row.cookIdsJson),
      SupabaseConstants.mealPlanEntryUpdatedAt:
          row.updatedAt.toIso8601String(),
    };
  }

  static List<String> _decodeCookIds(String? json) {
    if (json == null) return const [];
    try {
      return (jsonDecode(json) as List<dynamic>).cast<String>();
    } catch (_) {
      return const [];
    }
  }

  PendingChange _rowToPendingChange(LocalMealPlanEntry row) {
    final isDelete =
        LocalSyncStatus.fromDb(row.syncStatus) == LocalSyncStatus.pendingDelete;
    return PendingChange(
      id: row.localId,
      status: isDelete ? SyncItemStatus.pendingDelete : SyncItemStatus.pending,
      retryCount: 0,
      payload: const {},
    );
  }
}
