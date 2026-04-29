import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/tables/local_meal_plan_entries_table.dart';
import 'package:meal_planner/data/sync/local_sync_status.dart';
import 'package:meal_planner/data/sync/meal_plan_local_store.dart';

part 'meal_plan_dao.g.dart';

@DriftAccessor(tables: [LocalMealPlanEntries])
class MealPlanDao extends DatabaseAccessor<AppDatabase>
    with _$MealPlanDaoMixin
    implements MealPlanLocalStore {
  MealPlanDao(super.db);

  MealPlanRow _toRow(LocalMealPlanEntry r) => MealPlanRow(
        localId: r.localId,
        syncStatus: LocalSyncStatus.fromDb(r.syncStatus),
        remoteId: r.remoteId,
        recipeId: r.recipeId,
        customName: r.customName,
        date: r.date,
        mealType: r.mealType,
        cookIds: _decodeCookIds(r.cookIdsJson),
        updatedAt: r.updatedAt,
      );

  static List<String> _decodeCookIds(String? json) {
    if (json == null) return const [];
    try {
      return (jsonDecode(json) as List<dynamic>).cast<String>();
    } catch (_) {
      return const [];
    }
  }

  // Watch all entries for a specific date (UI stream)
  Stream<List<LocalMealPlanEntry>> watchEntriesForDate(
    String groupId,
    String date,
  ) {
    return (select(localMealPlanEntries)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) => t.date.equals(date))
          ..where((t) =>
              t.syncStatus.equals(LocalSyncStatus.pendingDelete.dbValue).not()))
        .watch();
  }

  // Watch all entries for a month – used by calendar to show dots on days
  Stream<List<LocalMealPlanEntry>> watchEntriesForMonth(
    String groupId,
    String yearMonth, // 'yyyy-MM'
  ) {
    return (select(localMealPlanEntries)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) => t.date.like('$yearMonth-%'))
          ..where((t) =>
              t.syncStatus.equals(LocalSyncStatus.pendingDelete.dbValue).not()))
        .watch();
  }

  // All entries not yet synced – used by SyncAdapter via MealPlanLocalStore
  @override
  Future<List<MealPlanRow>> getPendingEntries(String groupId) async {
    final rows = await (select(localMealPlanEntries)
          ..where((t) => t.groupId.equals(groupId))
          ..where(
              (t) => t.syncStatus.equals(LocalSyncStatus.synced.dbValue).not()))
        .get();
    return rows.map(_toRow).toList();
  }

  /// Returns the remote ids of all locally-pending entries (any non-`synced`
  /// status) that already have a remote counterpart. Used by `SyncEngine` to
  /// implement local-pending-wins on the pull phase.
  Future<Set<String>> getPendingRemoteIds(String groupId) async {
    final rows = await (select(localMealPlanEntries)
          ..where((t) => t.groupId.equals(groupId))
          ..where(
              (t) => t.syncStatus.equals(LocalSyncStatus.synced.dbValue).not())
          ..where((t) => t.remoteId.isNotNull()))
        .get();
    return rows.map((r) => r.remoteId!).toSet();
  }

  @override
  Future<MealPlanRow?> getEntryByLocalId(String localId) async {
    final row = await (select(localMealPlanEntries)
          ..where((t) => t.localId.equals(localId)))
        .getSingleOrNull();
    return row == null ? null : _toRow(row);
  }

  Future<void> upsertEntry(LocalMealPlanEntriesCompanion entry) {
    return into(localMealPlanEntries).insertOnConflictUpdate(entry);
  }

  Future<void> updateSyncStatus(
    String localId,
    LocalSyncStatus status, {
    String? remoteId,
  }) {
    return (update(localMealPlanEntries)
          ..where((t) => t.localId.equals(localId)))
        .write(LocalMealPlanEntriesCompanion(
      syncStatus: Value(status.dbValue),
      remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
    ));
  }

  Future<void> markAsDeleted(String localId) {
    return (update(localMealPlanEntries)
          ..where((t) => t.localId.equals(localId)))
        .write(LocalMealPlanEntriesCompanion(
      syncStatus: Value(LocalSyncStatus.pendingDelete.dbValue),
    ));
  }

  Future<void> updateCookIds(String localId, String? cookIdsJson) {
    return (update(localMealPlanEntries)
          ..where((t) => t.localId.equals(localId)))
        .write(LocalMealPlanEntriesCompanion(
      cookIdsJson: Value(cookIdsJson),
      syncStatus: Value(LocalSyncStatus.pendingUpdate.dbValue),
    ));
  }

  Future<void> updateEntry(
    String localId, {
    required String recipeId,
    String? customName,
    String? cookIdsJson,
    bool keepPendingCreate = false,
  }) {
    final status = keepPendingCreate
        ? LocalSyncStatus.pendingCreate
        : LocalSyncStatus.pendingUpdate;
    return (update(localMealPlanEntries)
          ..where((t) => t.localId.equals(localId)))
        .write(LocalMealPlanEntriesCompanion(
      recipeId: Value(recipeId),
      customName: Value(customName),
      cookIdsJson: Value(cookIdsJson),
      syncStatus: Value(status.dbValue),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Relocates an entry to a new slot (date + mealType). Leaves recipeId,
  /// customName and cookIdsJson untouched so callers can drag entire slots
  /// without having to round-trip the payload fields.
  Future<void> moveEntry(
    String localId, {
    required String date,
    required String mealType,
    bool keepPendingCreate = false,
  }) {
    final status = keepPendingCreate
        ? LocalSyncStatus.pendingCreate
        : LocalSyncStatus.pendingUpdate;
    return (update(localMealPlanEntries)
          ..where((t) => t.localId.equals(localId)))
        .write(LocalMealPlanEntriesCompanion(
      date: Value(date),
      mealType: Value(mealType),
      syncStatus: Value(status.dbValue),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Converts all meal plan entries that reference [recipeId] to free-text
  /// entries, preserving [recipeName] as [customName].
  /// Keeps syncStatus pendingCreate for unsynced entries; sets
  /// pendingUpdate for everything else so the sync pushes the change.
  Future<void> detachRecipeEntries(String recipeId, String recipeName) {
    return transaction(() async {
      await (update(localMealPlanEntries)
            ..where((t) => t.recipeId.equals(recipeId))
            ..where((t) => t.syncStatus
                .equals(LocalSyncStatus.pendingCreate.dbValue)
                .not()))
          .write(LocalMealPlanEntriesCompanion(
        recipeId: const Value(''),
        customName: Value(recipeName),
        syncStatus: Value(LocalSyncStatus.pendingUpdate.dbValue),
        updatedAt: Value(DateTime.now()),
      ));

      await (update(localMealPlanEntries)
            ..where((t) => t.recipeId.equals(recipeId))
            ..where((t) =>
                t.syncStatus.equals(LocalSyncStatus.pendingCreate.dbValue)))
          .write(LocalMealPlanEntriesCompanion(
        recipeId: const Value(''),
        customName: Value(recipeName),
        updatedAt: Value(DateTime.now()),
      ));
    });
  }

  Future<void> hardDeleteEntry(String localId) {
    return (delete(localMealPlanEntries)
          ..where((t) => t.localId.equals(localId)))
        .go();
  }

  /// Returns all non-deleted entries between [fromDate] and [toDate] inclusive.
  /// Dates must be formatted as 'yyyy-MM-dd'.
  Future<List<LocalMealPlanEntry>> getEntriesInRange(
    String groupId,
    String fromDate,
    String toDate,
  ) {
    return (select(localMealPlanEntries)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) => t.date.isBiggerOrEqualValue(fromDate))
          ..where((t) => t.date.isSmallerOrEqualValue(toDate))
          ..where((t) =>
              t.syncStatus.equals(LocalSyncStatus.pendingDelete.dbValue).not()))
        .get();
  }

  Future<void> hardDeleteByRemoteId(String remoteId) {
    return (delete(localMealPlanEntries)
          ..where((t) => t.remoteId.equals(remoteId)))
        .go();
  }

  // Replaces all synced entries for a month – used by MealPlanSyncAdapter
  @override
  Future<void> replaceAllSynced(
    String groupId,
    String yearMonth,
    List<MealPlanSyncedRow> rows,
  ) async {
    final companions = rows
        .map((r) => LocalMealPlanEntriesCompanion(
              localId: Value(r.localId),
              remoteId: Value(r.remoteId),
              groupId: Value(groupId),
              recipeId: Value(r.recipeId),
              customName: Value(r.customName),
              date: Value(r.date),
              mealType: Value(r.mealType),
              cookIdsJson: Value(
                  r.cookIds.isEmpty ? null : jsonEncode(r.cookIds)),
              syncStatus: Value(LocalSyncStatus.synced.dbValue),
              updatedAt: Value(DateTime.now()),
            ))
        .toList();

    await transaction(() async {
      await (delete(localMealPlanEntries)
            ..where((t) => t.groupId.equals(groupId))
            ..where((t) => t.date.like('$yearMonth-%'))
            ..where(
                (t) => t.syncStatus.equals(LocalSyncStatus.synced.dbValue)))
          .go();

      if (companions.isNotEmpty) {
        await batch((b) => b.insertAll(localMealPlanEntries, companions));
      }
    });
  }
}
