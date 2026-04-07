import 'dart:async';

import 'package:meal_planner/data/sync/sync_adapter.dart';
import 'package:meal_planner/data/sync/sync_types.dart';

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

    try {
      // ---- Push phase ----
      final pending = await adapter.readPending();
      for (final change in pending) {
        try {
          await adapter.pushOne(change);
          await adapter.markSynced(change.id);
          pushed++;
        } catch (e, st) {
          failed++;
          errors.add(SyncError(itemId: change.id, error: e, stackTrace: st));
          try {
            await adapter.markFailed(change.id, e);
          } catch (_) {
            // Swallow: failure to record the failure shouldn't abort the run.
          }
        }
      }

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
      final result = SyncResult(
        pushed: pushed,
        pulled: 0,
        failed: failed,
        errors: errors,
        fatalError: e,
        ranAt: startedAt,
      );
      _events.add(SyncEvent(
        featureKey: adapter.featureKey,
        scope: scope,
        phase: SyncPhase.failed,
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
