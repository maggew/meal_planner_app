import 'package:drift/drift.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/tables/local_meal_plan_entries_table.dart';
import 'package:meal_planner/data/sync/local_sync_status.dart';

part 'meal_plan_dao.g.dart';

@DriftAccessor(tables: [LocalMealPlanEntries])
class MealPlanDao extends DatabaseAccessor<AppDatabase>
    with _$MealPlanDaoMixin {
  MealPlanDao(super.db);

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

  // All entries not yet synced – used by SyncService
  Future<List<LocalMealPlanEntry>> getPendingEntries(String groupId) {
    return (select(localMealPlanEntries)
          ..where((t) => t.groupId.equals(groupId))
          ..where(
              (t) => t.syncStatus.equals(LocalSyncStatus.synced.dbValue).not()))
        .get();
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

  Future<LocalMealPlanEntry?> getEntryByLocalId(String localId) {
    return (select(localMealPlanEntries)
          ..where((t) => t.localId.equals(localId)))
        .getSingleOrNull();
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

  // Replaces all synced entries for a month – used by initial pull
  Future<void> replaceAllSynced(
    String groupId,
    String yearMonth,
    List<LocalMealPlanEntriesCompanion> entries,
  ) async {
    await transaction(() async {
      await (delete(localMealPlanEntries)
            ..where((t) => t.groupId.equals(groupId))
            ..where((t) => t.date.like('$yearMonth-%'))
            ..where(
                (t) => t.syncStatus.equals(LocalSyncStatus.synced.dbValue)))
          .go();

      if (entries.isNotEmpty) {
        await batch((b) => b.insertAll(localMealPlanEntries, entries));
      }
    });
  }
}
