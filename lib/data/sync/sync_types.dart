/// Value types exchanged between [SyncEngine] and a [SyncAdapter].
///
/// The engine speaks only in these types — adapters translate Drift rows and
/// Supabase DTOs to/from them. Keeping the engine free of feature types is
/// what makes one engine reusable for both meal plan and shopping list.
library;

/// Per-item sync state machine.
///
/// - [pending]: local create or update waiting to be pushed.
/// - [synced]: in sync with remote.
/// - [failed]: last push attempt threw; will be retried on the next trigger
///   together with [pending] (no exponential backoff).
/// - [pendingDelete]: local deletion waiting to be pushed; row is hard-deleted
///   locally on successful push.
enum SyncItemStatus { pending, synced, failed, pendingDelete }

/// A local row that the engine should push to the remote.
///
/// `payload` is opaque to the engine — the adapter encodes whatever its
/// `pushOne` needs (e.g. Supabase DTO map). `id` is the stable identifier
/// the engine uses to call back into the adapter (`markSynced`/`markFailed`).
class PendingChange {
  const PendingChange({
    required this.id,
    required this.status,
    required this.retryCount,
    required this.payload,
  });

  final String id;
  final SyncItemStatus status; // pending or pendingDelete
  final int retryCount;
  final Map<String, dynamic> payload;
}

/// A remote row returned by the adapter's `pullSince`. The engine pre-filters
/// rows whose `id` is in `localPendingIds` (local-pending-wins) and hands the
/// rest to `applyRemote` for a dumb upsert.
class RemoteRow {
  const RemoteRow({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.data,
  });

  final String id;
  final DateTime updatedAt;
  final bool deleted;
  final Map<String, dynamic> data;
}

/// Identifies the slice of data a sync run should cover.
///
/// `key` is persisted in `SyncMeta` together with the feature key, so each
/// scope has its own `lastPulledAt` cursor.
abstract class SyncScope {
  const SyncScope();
  String get key;
}

/// Pulls everything for the feature (e.g. shopping list).
class FullScope extends SyncScope {
  const FullScope();
  @override
  String get key => 'all';
}

/// Pulls a single calendar month (e.g. meal plan).
class MonthScope extends SyncScope {
  const MonthScope(this.year, this.month);
  final int year;
  final int month;
  @override
  String get key =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
}

/// One per-item failure during a sync run. Carries the originating exception
/// so callers can log/report without the engine deciding policy.
class SyncError {
  const SyncError({
    required this.itemId,
    required this.error,
    required this.stackTrace,
  });
  final String itemId;
  final Object error;
  final StackTrace stackTrace;
}

/// Outcome of a single `SyncEngine.sync` invocation.
///
/// `fatalError` is set when the run aborted before completing (e.g. the pull
/// query threw). Per-item push failures populate `errors` and `failed` but
/// do not set `fatalError`.
class SyncResult {
  const SyncResult({
    required this.pushed,
    required this.pulled,
    required this.failed,
    required this.errors,
    required this.fatalError,
    required this.ranAt,
  });

  final int pushed;
  final int pulled;
  final int failed;
  final List<SyncError> errors;
  final Object? fatalError;
  final DateTime ranAt;

  bool get ok => fatalError == null && failed == 0;
}

enum SyncPhase { started, finished, failed }

/// Observation event emitted on `SyncEngine.events`. Coordinator uses these
/// to drive UI feedback (sync indicator) without polling.
class SyncEvent {
  const SyncEvent({
    required this.featureKey,
    required this.scope,
    required this.phase,
    required this.at,
    this.result,
  });

  final String featureKey;
  final SyncScope scope;
  final SyncPhase phase;
  final SyncResult? result;
  final DateTime at;
}
