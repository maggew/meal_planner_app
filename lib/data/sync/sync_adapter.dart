import 'package:meal_planner/data/sync/sync_types.dart';

/// Feature-specific bridge between [SyncEngine] and a concrete data source.
///
/// Adapters are intentionally narrow and dumb: no policy, no scheduling, no
/// retry logic. The engine drives the workflow; the adapter only knows how to
/// read/write its Drift tables and how to talk to its Supabase endpoint.
///
/// Implementations must be safe to call from a single sync run at a time —
/// the engine guarantees no concurrent invocations for the same
/// `(featureKey, scope.key)` pair.
abstract class SyncAdapter {
  /// Stable identifier persisted in `SyncMeta` (e.g. `'meal_plan'`).
  String get featureKey;

  /// Returns rows whose status is `pending` or `pendingDelete`. The order
  /// determines push order; adapters typically sort by creation time so a
  /// create is pushed before its subsequent update.
  Future<List<PendingChange>> readPending();

  /// IDs of rows currently in `pending` or `pendingDelete`. The engine uses
  /// this to skip remote rows that the local user is editing
  /// (local-pending-wins conflict resolution).
  Future<Set<String>> localPendingIds();

  /// Marks the local row as `synced`. For a `pendingDelete` push, the
  /// adapter should hard-delete the row instead.
  Future<void> markSynced(String id);

  /// Marks the local row as `failed` and records `error` for debugging.
  /// Increments `retryCount` so callers can surface stuck items.
  Future<void> markFailed(String id, Object error);

  /// Upserts the given remote rows into local storage. The engine has already
  /// stripped rows whose ids are in [localPendingIds], so the adapter can do
  /// a dumb upsert without conflict checks.
  Future<void> applyRemote(List<RemoteRow> rows);

  /// Pushes a single change to the remote. Must throw on failure — the
  /// engine catches and routes the exception to [markFailed].
  Future<void> pushOne(PendingChange change);

  /// Returns remote rows updated strictly after [since] within [scope]. When
  /// [since] is `null`, returns all rows in scope (initial pull).
  Future<List<RemoteRow>> pullSince(DateTime? since, SyncScope scope);
}
