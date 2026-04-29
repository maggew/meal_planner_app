import 'package:meal_planner/data/sync/local_sync_status.dart';

/// A locally-stored meal plan entry exposed to the sync adapter.
///
/// Uses plain Dart types — no Drift `Value<>` wrappers or generated row
/// classes — so the adapter can be tested without spinning up Drift.
class MealPlanRow {
  const MealPlanRow({
    required this.localId,
    required this.syncStatus,
    this.remoteId,
    required this.recipeId,
    this.customName,
    required this.date,
    required this.mealType,
    required this.cookIds,
    required this.updatedAt,
  });

  final String localId;
  final LocalSyncStatus syncStatus;
  final String? remoteId;

  /// Empty string for free-text (customName) entries.
  final String recipeId;
  final String? customName;

  /// ISO date string 'yyyy-MM-dd'.
  final String date;
  final String mealType;
  final List<String> cookIds;
  final DateTime updatedAt;
}

/// A remote row to be written into local storage after a pull.
///
/// syncStatus is always [LocalSyncStatus.synced] — the DAO sets it
/// implicitly when calling [MealPlanLocalStore.replaceAllSynced].
class MealPlanSyncedRow {
  const MealPlanSyncedRow({
    required this.localId,
    required this.remoteId,
    required this.recipeId,
    this.customName,
    required this.date,
    required this.mealType,
    required this.cookIds,
  });

  final String localId;
  final String remoteId;
  final String recipeId;
  final String? customName;
  final String date;
  final String mealType;
  final List<String> cookIds;
}

/// Narrow DAO contract required by [MealPlanSyncAdapter].
///
/// Speaks only plain Dart and [LocalSyncStatus] — no Drift types.
/// [MealPlanDao] implements this; tests can supply a lightweight fake.
abstract class MealPlanLocalStore {
  /// All non-synced entries for [groupId].
  Future<List<MealPlanRow>> getPendingEntries(String groupId);

  /// Remote IDs of entries that are locally pending (local-pending-wins).
  Future<Set<String>> getPendingRemoteIds(String groupId);

  /// Single entry by local UUID, or null if concurrently deleted.
  Future<MealPlanRow?> getEntryByLocalId(String localId);

  Future<void> updateSyncStatus(
    String localId,
    LocalSyncStatus status, {
    String? remoteId,
  });

  Future<void> hardDeleteEntry(String localId);

  /// Atomically replaces all synced entries for [yearMonth] ('yyyy-MM')
  /// with [rows]. Pending entries are never touched.
  Future<void> replaceAllSynced(
    String groupId,
    String yearMonth,
    List<MealPlanSyncedRow> rows,
  );
}
