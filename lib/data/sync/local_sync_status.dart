/// DB-level sync state machine for local Drift rows.
///
/// All five values map 1-to-1 to the `syncStatus` TEXT column in
/// `LocalMealPlanEntries` and `LocalShoppingItems`.  Call [dbValue] to get
/// the exact string that is persisted; use [fromDb] to parse it back.
///
/// The engine-level [SyncItemStatus] (in sync_types.dart) is a separate,
/// coarser enum — it collapses pendingCreate and pendingUpdate into a single
/// `pending` value because the engine does not need to distinguish them.
enum LocalSyncStatus {
  pendingCreate,
  pendingUpdate,
  pendingDelete,
  synced,
  failed;

  String get dbValue => switch (this) {
        LocalSyncStatus.pendingCreate => 'pendingCreate',
        LocalSyncStatus.pendingUpdate => 'pendingUpdate',
        LocalSyncStatus.pendingDelete => 'pendingDelete',
        LocalSyncStatus.synced => 'synced',
        LocalSyncStatus.failed => 'failed',
      };

  static LocalSyncStatus fromDb(String value) => switch (value) {
        'pendingCreate' => LocalSyncStatus.pendingCreate,
        'pendingUpdate' => LocalSyncStatus.pendingUpdate,
        'pendingDelete' => LocalSyncStatus.pendingDelete,
        'synced' => LocalSyncStatus.synced,
        'failed' => LocalSyncStatus.failed,
        _ => throw ArgumentError('Unknown LocalSyncStatus: $value'),
      };
}
