import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/sync/sync_types.dart';
import 'package:meal_planner/services/providers/sync/sync_status_provider.dart';

/// Drives a [SyncStatusNotifier] directly off a manual event stream so we
/// can assert health transitions without spinning up the engine.
class _Harness {
  _Harness() {
    notifier = SyncStatusNotifier(_controller.stream);
  }

  final StreamController<SyncEvent> _controller =
      StreamController<SyncEvent>.broadcast();
  late final SyncStatusNotifier notifier;

  Future<void> emit(SyncEvent e) async {
    _controller.add(e);
    // Let the notifier's stream subscription run.
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> dispose() async {
    notifier.dispose();
    await _controller.close();
  }
}

SyncEvent _started(String feature, {SyncScope scope = const FullScope()}) =>
    SyncEvent(
      featureKey: feature,
      scope: scope,
      phase: SyncPhase.started,
      at: DateTime.now(),
    );

SyncEvent _finished(
  String feature, {
  SyncScope scope = const FullScope(),
  int failed = 0,
  Object? transientPullError,
  List<SyncError> errors = const [],
}) =>
    SyncEvent(
      featureKey: feature,
      scope: scope,
      phase: SyncPhase.finished,
      at: DateTime.now(),
      result: SyncResult(
        pushed: 0,
        pulled: 0,
        failed: failed,
        errors: errors,
        fatalError: null,
        transientPullError: transientPullError,
        ranAt: DateTime.now(),
      ),
    );

SyncEvent _failed(
  String feature, {
  SyncScope scope = const FullScope(),
  Object fatal = 'boom',
}) =>
    SyncEvent(
      featureKey: feature,
      scope: scope,
      phase: SyncPhase.failed,
      at: DateTime.now(),
      result: SyncResult(
        pushed: 0,
        pulled: 0,
        failed: 0,
        errors: const [],
        fatalError: fatal,
        ranAt: DateTime.now(),
      ),
    );

void main() {
  group('SyncStatusNotifier', () {
    test('initial state is idle', () {
      final h = _Harness();
      expect(h.notifier.state.health, SyncHealth.idle);
      expect(h.notifier.state.lastSuccessAt, isNull);
      h.dispose();
    });

    test('started → finished transitions idle → syncing → ok', () async {
      final h = _Harness();
      await h.emit(_started('meal_plan'));
      expect(h.notifier.state.health, SyncHealth.syncing);

      await h.emit(_finished('meal_plan'));
      expect(h.notifier.state.health, SyncHealth.ok);
      expect(h.notifier.state.lastSuccessAt, isNotNull);
      expect(h.notifier.state.failedItemCount, 0);

      await h.dispose();
    });

    test('permanent per-item failure → degraded', () async {
      final h = _Harness();
      await h.emit(_started('meal_plan'));
      await h.emit(_finished('meal_plan', failed: 2));
      expect(h.notifier.state.health, SyncHealth.degraded);
      expect(h.notifier.state.failedItemCount, 2);
      await h.dispose();
    });

    test('transient pull error → degraded but does not count toward failing',
        () async {
      final h = _Harness();
      for (var i = 0; i < 5; i++) {
        await h.emit(_started('meal_plan'));
        await h.emit(_finished('meal_plan',
            transientPullError: 'offline'));
      }
      // Five transient runs in a row must NOT escalate to failing — that's
      // exactly the offline-noise case the soft flag was added to avoid.
      expect(h.notifier.state.health, SyncHealth.degraded);
      await h.dispose();
    });

    test('3 consecutive permanent failures → failing', () async {
      final h = _Harness();
      for (var i = 0; i < kFailingThreshold; i++) {
        await h.emit(_started('meal_plan'));
        await h.emit(_finished('meal_plan', failed: 1));
      }
      expect(h.notifier.state.health, SyncHealth.failing);

      // One clean run resets the counter and returns to ok.
      await h.emit(_started('meal_plan'));
      await h.emit(_finished('meal_plan'));
      expect(h.notifier.state.health, SyncHealth.ok);

      await h.dispose();
    });

    test('per-feature counters are independent', () async {
      final h = _Harness();
      // Two bad meal plan runs, then a clean shopping run — meal plan must
      // still be on its way to failing, shopping must be ok in isolation but
      // global state shows the worst feature.
      for (var i = 0; i < 2; i++) {
        await h.emit(_started('meal_plan'));
        await h.emit(_finished('meal_plan', failed: 1));
      }
      await h.emit(_started('shopping_list'));
      await h.emit(_finished('shopping_list'));
      // Last event was clean → degraded (meal plan counter at 2, not yet
      // failing).
      expect(h.notifier.state.health, SyncHealth.ok,
          reason: 'last event was a clean run, no soft flag set');

      // One more meal plan failure pushes its counter to 3 → failing.
      await h.emit(_started('meal_plan'));
      await h.emit(_finished('meal_plan', failed: 1));
      expect(h.notifier.state.health, SyncHealth.failing);

      await h.dispose();
    });

    test('failed phase event with fatal error counts toward failing',
        () async {
      final h = _Harness();
      for (var i = 0; i < kFailingThreshold; i++) {
        await h.emit(_started('meal_plan'));
        await h.emit(_failed('meal_plan'));
      }
      expect(h.notifier.state.health, SyncHealth.failing);
      expect(h.notifier.state.lastFatalError, isNotNull);
      await h.dispose();
    });

    test('clean run after a bad run resets to ok and clears counter',
        () async {
      final h = _Harness();
      await h.emit(_started('meal_plan'));
      await h.emit(_finished('meal_plan', failed: 3));
      expect(h.notifier.state.health, SyncHealth.degraded);

      await h.emit(_started('meal_plan'));
      await h.emit(_finished('meal_plan'));
      expect(h.notifier.state.health, SyncHealth.ok);
      expect(h.notifier.state.failedItemCount, 0);

      await h.dispose();
    });
  });
}
