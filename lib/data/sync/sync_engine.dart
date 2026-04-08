import 'dart:async';
import 'dart:io';

import 'package:meal_planner/data/sync/sync_adapter.dart';
import 'package:meal_planner/data/sync/sync_types.dart';

/// Classifies a thrown error as transient (offline/network) or permanent.
///
/// Transient: anything that the next sync trigger has a real chance of
/// resolving without the user or developer doing anything — typically a
/// dropped connection. Caught here so transient failures don't pollute
/// `retryCount` or flip rows to `failed` (which would also block future
/// retries from the regular `pending` filter once backoff lands).
SyncErrorKind classifySyncError(Object error) {
  if (error is SocketException) return SyncErrorKind.transient;
  if (error is TimeoutException) return SyncErrorKind.transient;
  if (error is HttpException) return SyncErrorKind.transient;
  return SyncErrorKind.permanent;
}

/// Narrow persistence interface the engine needs from `SyncMetaDao`.
///
/// Declared as an interface (not a direct DAO dependency) so tests can supply
/// an in-memory store without spinning up Drift.
abstract class SyncMetaStore {
  Future<DateTime?> getLastPulledAt(String featureKey, String scopeKey);
  Future<void> setLastPulledAt(
      String featureKey, String scopeKey, DateTime pulledAt);
}

/// Stateless offline-first sync runner.
///
/// One engine instance is shared by all features. Feature-specific behavior
/// lives in [SyncAdapter]; scheduling/triggers live in `SyncCoordinator`.
///
/// A single [sync] call performs:
///   1. push every [PendingChange] one by one (per-item try/catch),
///   2. pull remote rows updated since the last successful pull,
///   3. drop rows that are still locally pending (local-pending-wins),
///   4. apply the rest via the adapter,
///   5. record the new `lastPulledAt`.
///
/// Concurrent calls for the same `(featureKey, scope.key)` are deduped: the
/// second caller awaits the in-flight future instead of starting a parallel
/// run. Different scopes for the same feature run independently.
class SyncEngine {
  SyncEngine(this._meta);

  final SyncMetaStore _meta;
  final Map<String, Future<SyncResult>> _inFlight = {};
  final StreamController<SyncEvent> _events =
      StreamController<SyncEvent>.broadcast();

  /// Observation stream. Coordinator/UI can listen to drive sync indicators
  /// without polling. Never closed for the engine's lifetime.
  Stream<SyncEvent> get events => _events.stream;

  /// Runs one push+pull cycle for [adapter] within [scope].
  ///
  /// Returns the existing in-flight future if a run for the same
  /// `(featureKey, scope.key)` is already underway.
  Future<SyncResult> sync(SyncAdapter adapter, SyncScope scope) {
    final key = '${adapter.featureKey}:${scope.key}';
    final existing = _inFlight[key];
    if (existing != null) return existing;
    final fut = _run(adapter, scope);
    _inFlight[key] = fut;
    return fut.whenComplete(() => _inFlight.remove(key));
  }

  Future<SyncResult> _run(SyncAdapter adapter, SyncScope scope) async {
    final startedAt = DateTime.now();
    _events.add(SyncEvent(
      featureKey: adapter.featureKey,
      scope: scope,
      phase: SyncPhase.started,
      at: startedAt,
    ));

    var pushed = 0;
    var failed = 0;
    final errors = <SyncError>[];

    // ---- Push phase ----
    // Push errors are caught per-item; the loop never throws to the outer
    // catch. The outer catch is reserved for the pull phase.
    final pending = await adapter.readPending();
    for (final change in pending) {
      try {
        await adapter.pushOne(change);
        await adapter.markSynced(change.id);
        pushed++;
      } catch (e, st) {
        final kind = classifySyncError(e);
        errors.add(SyncError(
          itemId: change.id,
          error: e,
          stackTrace: st,
          kind: kind,
        ));
        if (kind == SyncErrorKind.permanent) {
          failed++;
          try {
            await adapter.markFailed(change.id, e);
          } catch (_) {
            // Swallow: failure to record the failure shouldn't abort the run.
          }
        }
        // Transient: leave the row exactly as it was. The next trigger (or
        // the connectivity-restore branch in the coordinator) will retry it
        // through the normal pending path.
      }
    }

    try {
      // ---- Pull phase ----
      // Capture the cutoff before issuing the query so concurrent remote
      // writes that land mid-pull are still picked up by the next run.
      final pullStartedAt = DateTime.now();
      final since = await _meta.getLastPulledAt(adapter.featureKey, scope.key);
      final remote = await adapter.pullSince(since, scope);

      final localPending = await adapter.localPendingIds();
      final filtered = localPending.isEmpty
          ? remote
          : remote.where((r) => !localPending.contains(r.id)).toList();

      if (filtered.isNotEmpty) {
        await adapter.applyRemote(filtered);
      }

      await _meta.setLastPulledAt(
        adapter.featureKey,
        scope.key,
        pullStartedAt,
      );

      final result = SyncResult(
        pushed: pushed,
        pulled: filtered.length,
        failed: failed,
        errors: errors,
        fatalError: null,
        ranAt: startedAt,
      );
      _events.add(SyncEvent(
        featureKey: adapter.featureKey,
        scope: scope,
        phase: SyncPhase.finished,
        result: result,
        at: DateTime.now(),
      ));
      return result;
    } catch (e) {
      final kind = classifySyncError(e);
      final result = SyncResult(
        pushed: pushed,
        pulled: 0,
        failed: failed,
        errors: errors,
        fatalError: kind == SyncErrorKind.permanent ? e : null,
        transientPullError: kind == SyncErrorKind.transient ? e : null,
        ranAt: startedAt,
      );
      // Transient pull failures still emit `finished` (with the soft flag set)
      // so the status provider doesn't escalate to `failing` over a dropped
      // connection mid-request. Permanent pull failures emit `failed`.
      _events.add(SyncEvent(
        featureKey: adapter.featureKey,
        scope: scope,
        phase: kind == SyncErrorKind.permanent
            ? SyncPhase.failed
            : SyncPhase.finished,
        result: result,
        at: DateTime.now(),
      ));
      return result;
    }
  }

  /// Releases the events stream. Tests should call this; production keeps the
  /// engine alive for the app lifetime.
  Future<void> dispose() => _events.close();
}
