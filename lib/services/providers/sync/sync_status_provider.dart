import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meal_planner/data/sync/sync_types.dart';
import 'package:meal_planner/services/providers/sync/sync_providers.dart';

/// User-facing sync health.
///
/// - [idle]: no run has happened yet (cold start).
/// - [syncing]: at least one run is in flight right now.
/// - [ok]: most recent run completed cleanly.
/// - [degraded]: most recent run had a permanent per-item failure or a
///   transient pull error. Visible warning, but recoverable on the next run.
/// - [failing]: 3 consecutive bad runs for the same feature — something is
///   actually broken (RLS, schema, server). Time to surface loudly.
enum SyncHealth { idle, syncing, ok, degraded, failing }

/// Immutable snapshot consumed by the AppBar indicator (step 4) and any
/// future telemetry. Built from `SyncEngine.events`.
@immutable
class SyncStatus {
  const SyncStatus({
    required this.health,
    required this.failedItemCount,
    required this.lastSuccessAt,
    required this.lastFatalError,
    required this.lastEventAt,
  });

  const SyncStatus.initial()
      : health = SyncHealth.idle,
        failedItemCount = 0,
        lastSuccessAt = null,
        lastFatalError = null,
        lastEventAt = null;

  final SyncHealth health;
  final int failedItemCount;
  final DateTime? lastSuccessAt;
  final Object? lastFatalError;
  final DateTime? lastEventAt;

  SyncStatus copyWith({
    SyncHealth? health,
    int? failedItemCount,
    DateTime? lastSuccessAt,
    Object? lastFatalError,
    DateTime? lastEventAt,
    bool clearFatal = false,
  }) {
    return SyncStatus(
      health: health ?? this.health,
      failedItemCount: failedItemCount ?? this.failedItemCount,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastFatalError: clearFatal ? null : (lastFatalError ?? this.lastFatalError),
      lastEventAt: lastEventAt ?? this.lastEventAt,
    );
  }
}

/// Threshold for escalating from `degraded` to `failing`.
const int kFailingThreshold = 3;

/// Listens to `SyncEngine.events`, derives a single [SyncStatus], and logs
/// every event with a stable tag so dev consoles get one place to watch.
///
/// Logging only — no Crashlytics, no user dialogs. The AppBar indicator
/// (step 4) is the only user-visible surface.
class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  SyncStatusNotifier(Stream<SyncEvent> events)
      : super(const SyncStatus.initial()) {
    _sub = events.listen(_onEvent);
  }

  late final StreamSubscription<SyncEvent> _sub;

  /// In-flight runs keyed by `feature:scope`. Non-empty → health is `syncing`.
  final Set<String> _inFlight = {};

  /// Per-feature consecutive bad-run counter. Reset on every clean run.
  /// Transient pull errors do NOT bump this — they cause `degraded`, not
  /// `failing`, because they typically resolve themselves on the next trigger.
  final Map<String, int> _consecutiveBad = {};

  /// Was the most recent terminal event "bad" (permanent failure or transient
  /// pull error)? Drives `degraded` once nothing is in flight.
  bool _lastWasBad = false;

  void _onEvent(SyncEvent e) {
    _log(e);
    final key = '${e.featureKey}:${e.scope.key}';

    switch (e.phase) {
      case SyncPhase.started:
        _inFlight.add(key);
        state = state.copyWith(
          health: SyncHealth.syncing,
          lastEventAt: e.at,
        );
        return;

      case SyncPhase.finished:
      case SyncPhase.failed:
        _inFlight.remove(key);
        final result = e.result;
        if (result == null) return;

        final hadPermanent =
            result.failed > 0 || result.fatalError != null;
        final hadTransientSoftPull = result.transientPullError != null;

        if (hadPermanent) {
          final next = (_consecutiveBad[e.featureKey] ?? 0) + 1;
          _consecutiveBad[e.featureKey] = next;
          _lastWasBad = true;
        } else {
          _consecutiveBad[e.featureKey] = 0;
          _lastWasBad = hadTransientSoftPull;
        }

        final failing = _consecutiveBad.values
            .any((c) => c >= kFailingThreshold);

        SyncHealth nextHealth;
        if (_inFlight.isNotEmpty) {
          nextHealth = SyncHealth.syncing;
        } else if (failing) {
          nextHealth = SyncHealth.failing;
        } else if (_lastWasBad) {
          nextHealth = SyncHealth.degraded;
        } else {
          nextHealth = SyncHealth.ok;
        }

        state = SyncStatus(
          health: nextHealth,
          failedItemCount: result.failed,
          lastSuccessAt: hadPermanent ? state.lastSuccessAt : e.at,
          lastFatalError: result.fatalError ??
              result.transientPullError ??
              (hadPermanent ? state.lastFatalError : null),
          lastEventAt: e.at,
        );
        return;
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Centralized log sink. Single function so we can later swap to a real
/// logger without grepping the codebase. Strict scope: dev console during
/// testing — production builds drop `debugPrint`.
void _log(SyncEvent e) {
  final tag = '[sync:${e.featureKey}/${e.scope.key}]';
  switch (e.phase) {
    case SyncPhase.started:
      debugPrint('$tag started');
      return;
    case SyncPhase.finished:
      final r = e.result;
      if (r == null) {
        debugPrint('$tag finished');
        return;
      }
      debugPrint(
        '$tag finished pushed=${r.pushed} pulled=${r.pulled} '
        'failed=${r.failed}'
        '${r.transientPullError != null ? " transient=${r.transientPullError}" : ""}',
      );
      for (final err in r.errors) {
        debugPrint('$tag  · ${err.kind.name} item=${err.itemId}: ${err.error}');
      }
      return;
    case SyncPhase.failed:
      final r = e.result;
      debugPrint('$tag FAILED fatal=${r?.fatalError}');
      return;
  }
}

final syncStatusProvider =
    StateNotifierProvider<SyncStatusNotifier, SyncStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return SyncStatusNotifier(engine.events);
});
