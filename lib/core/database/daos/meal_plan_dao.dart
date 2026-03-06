import 'package:drift/drift.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/tables/local_meal_plan_entries_table.dart';

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
          ..where((t) => t.syncStatus.equals('pendingDelete').not()))
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
          ..where((t) => t.syncStatus.equals('pendingDelete').not()))
        .watch();
  }

  // All entries not yet synced – used by SyncService
  Future<List<LocalMealPlanEntry>> getPendingEntries(String groupId) {
    return (select(localMealPlanEntries)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) => t.syncStatus.equals('synced').not()))
        .get();
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
    String status, {
    String? remoteId,
  }) {
    return (update(localMealPlanEntries)
          ..where((t) => t.localId.equals(localId)))
        .write(LocalMealPlanEntriesCompanion(
      syncStatus: Value(status),
      remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
    ));
  }

  Future<void> markAsDeleted(String localId) {
    return (update(localMealPlanEntries)
          ..where((t) => t.localId.equals(localId)))
        .write(const LocalMealPlanEntriesCompanion(
      syncStatus: Value('pendingDelete'),
    ));
  }

  Future<void> updateCookIds(String localId, String? cookIdsJson) {
    return (update(localMealPlanEntries)
          ..where((t) => t.localId.equals(localId)))
        .write(LocalMealPlanEntriesCompanion(
      cookIdsJson: Value(cookIdsJson),
      syncStatus: const Value('pendingUpdate'),
    ));
  }

  Future<void> updateEntry(
    String localId, {
    required String recipeId,
    String? customName,
    String? cookIdsJson,
    bool keepPendingCreate = false,
  }) {
    return (update(localMealPlanEntries)
          ..where((t) => t.localId.equals(localId)))
        .write(LocalMealPlanEntriesCompanion(
      recipeId: Value(recipeId),
      customName: Value(customName),
      cookIdsJson: Value(cookIdsJson),
      syncStatus:
          Value(keepPendingCreate ? 'pendingCreate' : 'pendingUpdate'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Converts all meal plan entries that reference [recipeId] to free-text
  /// entries, preserving [recipeName] as [customName].
  /// Keeps syncStatus 'pendingCreate' for unsynced entries; sets
  /// 'pendingUpdate' for everything else so the sync pushes the change.
  Future<void> detachRecipeEntries(String recipeId, String recipeName) {
    return transaction(() async {
      await (update(localMealPlanEntries)
            ..where((t) => t.recipeId.equals(recipeId))
            ..where((t) => t.syncStatus.equals('pendingCreate').not()))
          .write(LocalMealPlanEntriesCompanion(
        recipeId: const Value(''),
        customName: Value(recipeName),
        syncStatus: const Value('pendingUpdate'),
        updatedAt: Value(DateTime.now()),
      ));

      await (update(localMealPlanEntries)
            ..where((t) => t.recipeId.equals(recipeId))
            ..where((t) => t.syncStatus.equals('pendingCreate')))
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

  /// Returns all non-deleted entries for the last [days] days (inclusive today)
  Future<List<LocalMealPlanEntry>> getRecentEntries(
    String groupId,
    int days,
  ) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffStr =
        '${cutoff.year.toString().padLeft(4, '0')}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';
    return (select(localMealPlanEntries)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) => t.date.isBiggerOrEqualValue(cutoffStr))
          ..where((t) => t.syncStatus.equals('pendingDelete').not()))
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
            ..where((t) => t.syncStatus.equals('synced')))
          .go();

      if (entries.isNotEmpty) {
        await batch((b) => b.insertAll(localMealPlanEntries, entries));
      }
    });
  }
}
