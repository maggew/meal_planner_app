import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/sync/sync_adapter.dart';
import 'package:meal_planner/data/sync/sync_coordinator.dart';
import 'package:meal_planner/data/sync/sync_engine.dart';
import 'package:meal_planner/data/sync/sync_types.dart';

/// In-memory `SyncMetaStore` so the engine has a real backing store.
class _InMemoryMeta implements SyncMetaStore {
  final Map<String, DateTime> _store = {};
  String _k(String f, String s) => '$f:$s';
  @override
  Future<DateTime?> getLastPulledAt(String f, String s) async =>
      _store[_k(f, s)];
  @override
  Future<void> setLastPulledAt(String f, String s, DateTime at) async {
    _store[_k(f, s)] = at;
  }
}

/// Counts how often the engine drove a sync against this adapter and which
/// scope was used. Optionally throws on `pullSince` to exercise the
/// `syncAll` failure-isolation path.
class _CountingAdapter implements SyncAdapter {
  _CountingAdapter(this.featureKey, {this.throwOnPull = false});

  @override
  final String featureKey;
  final bool throwOnPull;

  int syncs = 0;
  final List<String> scopeKeys = [];

  @override
  Future<List<PendingChange>> readPending() async => const [];

  @override
  Future<Set<String>> localPendingIds() async => const {};

  @override
  Future<void> markSynced(String id) async {}

  @override
  Future<void> markFailed(String id, Object error) async {}

  @override
  Future<void> applyRemote(List<RemoteRow> rows) async {}

  @override
  Future<void> pushOne(PendingChange change) async {}

  @override
  Future<List<RemoteRow>> pullSince(DateTime? since, SyncScope scope) async {
    syncs += 1;
    scopeKeys.add(scope.key);
    if (throwOnPull) throw StateError('pull failed for $featureKey');
    return const [];
  }
}

/// Builds a coordinator wired to the real engine + the supplied adapters and
/// a manual connectivity stream.
({
  SyncCoordinator coordinator,
  StreamController<List<ConnectivityResult>> connectivity,
  SyncEngine engine,
}) _build({
  required _CountingAdapter mealPlan,
  required _CountingAdapter shopping,
  bool Function()? isOnline,
}) {
  final connectivity = StreamController<List<ConnectivityResult>>.broadcast();
  final engine = SyncEngine(_InMemoryMeta());
  final coordinator = SyncCoordinator(
    engine: engine,
    mealPlan: mealPlan,
    shopping: shopping,
    connectivityStream: connectivity.stream,
    isOnline: isOnline ?? (() => true),
  );
  return (
    coordinator: coordinator,
    connectivity: connectivity,
    engine: engine,
  );
}

void main() {
  // The coordinator uses WidgetsBindingObserver, which needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncCoordinator', () {
    group('shopping list polling', () {
      test('fires immediately on enable, then every 10s, until disabled', () {
        fakeAsync((async) {
          final shopping = _CountingAdapter('shopping_list');
          final mealPlan = _CountingAdapter('meal_plan');
          final wired = _build(mealPlan: mealPlan, shopping: shopping);

          wired.coordinator.enableShoppingListPolling();
          async.flushMicrotasks();
          expect(shopping.syncs, 1, reason: 'should fire immediately');

          async.elapse(const Duration(seconds: 10));
          expect(shopping.syncs, 2, reason: 'one tick at 10s');

          async.elapse(const Duration(seconds: 10));
          expect(shopping.syncs, 3, reason: 'another tick at 20s');

          wired.coordinator.disableShoppingListPolling();
          async.flushMicrotasks();
          expect(shopping.syncs, 4, reason: 'flush fired on disable');

          async.elapse(const Duration(seconds: 30));
          expect(shopping.syncs, 4, reason: 'no further syncs after disable');

          // Meal plan was never enabled — coordinator must not have touched it.
          expect(mealPlan.syncs, 0);

          wired.coordinator.stop();
          wired.connectivity.close();
          wired.engine.dispose();
        });
      });

      test('enable is idempotent — does not stack timers', () {
        fakeAsync((async) {
          final shopping = _CountingAdapter('shopping_list');
          final mealPlan = _CountingAdapter('meal_plan');
          final wired = _build(mealPlan: mealPlan, shopping: shopping);

          wired.coordinator.enableShoppingListPolling();
          wired.coordinator.enableShoppingListPolling();
          wired.coordinator.enableShoppingListPolling();
          async.flushMicrotasks();
          // Only the first enable should have fired the immediate sync;
          // subsequent enables short-circuit because the timer is already
          // active.
          expect(shopping.syncs, 1);

          async.elapse(const Duration(seconds: 10));
          expect(shopping.syncs, 2,
              reason: 'one tick = one sync, not three');

          wired.coordinator.disableShoppingListPolling();
          async.flushMicrotasks();
          expect(shopping.syncs, 3, reason: 'flush fired on disable');

          wired.coordinator.stop();
          wired.connectivity.close();
          wired.engine.dispose();
        });
      });
    });

    group('meal plan polling', () {
      test('fires immediately, ticks every 30s, scoped to enabled month', () {
        fakeAsync((async) {
          final mealPlan = _CountingAdapter('meal_plan');
          final shopping = _CountingAdapter('shopping_list');
          final wired = _build(mealPlan: mealPlan, shopping: shopping);

          wired.coordinator.enableMealPlanPolling(DateTime(2026, 4, 15));
          async.flushMicrotasks();
          expect(mealPlan.syncs, 1);
          expect(mealPlan.scopeKeys, ['2026-04']);

          async.elapse(const Duration(seconds: 30));
          expect(mealPlan.syncs, 2);
          expect(mealPlan.scopeKeys.last, '2026-04');

          wired.coordinator.disableMealPlanPolling();
          async.flushMicrotasks();
          expect(mealPlan.syncs, 3, reason: 'flush fired on disable');

          async.elapse(const Duration(minutes: 5));
          expect(mealPlan.syncs, 3, reason: 'no further syncs after disable');

          wired.coordinator.stop();
          wired.connectivity.close();
          wired.engine.dispose();
        });
      });

      test('updateMealPlanMonth retargets without restarting the timer', () {
        fakeAsync((async) {
          final mealPlan = _CountingAdapter('meal_plan');
          final shopping = _CountingAdapter('shopping_list');
          final wired = _build(mealPlan: mealPlan, shopping: shopping);

          wired.coordinator.enableMealPlanPolling(DateTime(2026, 4, 1));
          async.flushMicrotasks();
          expect(mealPlan.scopeKeys, ['2026-04']);

          // 10s in — well before the next 30s tick — user pages forward.
          async.elapse(const Duration(seconds: 10));
          wired.coordinator.updateMealPlanMonth(DateTime(2026, 5, 1));
          async.flushMicrotasks();
          // Update fires an immediate sync against the new month.
          expect(mealPlan.scopeKeys, ['2026-04', '2026-05']);

          // The original 30s timer is still running on the old cadence —
          // 20s more elapses and we expect the next periodic tick, now
          // targeting the *new* month.
          async.elapse(const Duration(seconds: 20));
          expect(mealPlan.scopeKeys, ['2026-04', '2026-05', '2026-05']);

          wired.coordinator.disableMealPlanPolling();
          wired.coordinator.stop();
          wired.connectivity.close();
          wired.engine.dispose();
        });
      });
    });

    group('connectivity restore', () {
      test('flushes shopping list unconditionally; meal plan only when open',
          () {
        fakeAsync((async) {
          final mealPlan = _CountingAdapter('meal_plan');
          final shopping = _CountingAdapter('shopping_list');
          final wired = _build(mealPlan: mealPlan, shopping: shopping);

          wired.coordinator.start();
          wired.coordinator.enableShoppingListPolling();
          async.flushMicrotasks();
          final shoppingBaseline = shopping.syncs; // 1 (immediate fire)

          // Simulate offline → online transition. Meal plan polling is
          // *not* enabled, so the coordinator must not touch it on restore.
          wired.connectivity.add([ConnectivityResult.none]);
          async.flushMicrotasks();
          wired.connectivity.add([ConnectivityResult.wifi]);
          async.flushMicrotasks();

          expect(shopping.syncs, shoppingBaseline + 1,
              reason: 'shopping flushed on restore');
          expect(mealPlan.syncs, 0,
              reason: 'meal plan page closed → not touched');

          wired.coordinator.disableShoppingListPolling();
          wired.coordinator.stop();
          wired.connectivity.close();
          wired.engine.dispose();
        });
      });

      test('shopping list flushed on restore even when page is closed', () {
        fakeAsync((async) {
          final mealPlan = _CountingAdapter('meal_plan');
          final shopping = _CountingAdapter('shopping_list');
          final wired = _build(mealPlan: mealPlan, shopping: shopping);

          wired.coordinator.start();
          // Shopping page is NOT open — no polling enabled.

          wired.connectivity.add([ConnectivityResult.none]);
          async.flushMicrotasks();
          wired.connectivity.add([ConnectivityResult.wifi]);
          async.flushMicrotasks();

          expect(shopping.syncs, 1,
              reason: 'pending items flushed even with page closed');
          expect(mealPlan.syncs, 0,
              reason: 'meal plan not open → not touched');

          wired.coordinator.stop();
          wired.connectivity.close();
          wired.engine.dispose();
        });
      });

      test('online→online transition does nothing', () {
        fakeAsync((async) {
          final mealPlan = _CountingAdapter('meal_plan');
          final shopping = _CountingAdapter('shopping_list');
          final wired = _build(mealPlan: mealPlan, shopping: shopping);

          wired.coordinator.start();
          wired.coordinator.enableShoppingListPolling();
          async.flushMicrotasks();
          final baseline = shopping.syncs;

          // First connectivity event is "online" — _wasOffline starts false,
          // so this should be a no-op for sync (but it does flip the flag).
          wired.connectivity.add([ConnectivityResult.wifi]);
          async.flushMicrotasks();
          expect(shopping.syncs, baseline,
              reason: 'no offline→online transition yet');

          wired.coordinator.disableShoppingListPolling();
          wired.coordinator.stop();
          wired.connectivity.close();
          wired.engine.dispose();
        });
      });
    });

    group('syncAll', () {
      test('runs both features and isolates per-feature failures', () async {
        final mealPlan = _CountingAdapter('meal_plan', throwOnPull: true);
        final shopping = _CountingAdapter('shopping_list');
        final wired = _build(mealPlan: mealPlan, shopping: shopping);

        await wired.coordinator.syncAll(DateTime(2026, 4, 1));

        expect(mealPlan.syncs, 1, reason: 'meal plan attempted');
        expect(shopping.syncs, 1,
            reason: 'shopping ran despite meal plan failure');

        wired.coordinator.stop();
        await wired.connectivity.close();
        await wired.engine.dispose();
      });

      test(
          'syncAll surfaces per-feature failures through the event stream '
          '(no longer swallowed) while still completing the healthy feature',
          () async {
        final mealPlan = _CountingAdapter('meal_plan', throwOnPull: true);
        final shopping = _CountingAdapter('shopping_list');
        final wired = _build(mealPlan: mealPlan, shopping: shopping);

        final events = <SyncEvent>[];
        final sub = wired.engine.events.listen(events.add);

        await wired.coordinator.syncAll(DateTime(2026, 4, 1));
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        // Healthy feature still ran to completion.
        expect(shopping.syncs, 1);
        expect(mealPlan.syncs, 1);

        // Both terminal phases observed — one finished (shopping), one failed
        // (meal plan, since StateError is permanent post-step-2).
        final phases = events.map((e) => e.phase).toList();
        expect(phases, contains(SyncPhase.finished));
        expect(phases, contains(SyncPhase.failed));

        wired.coordinator.stop();
        await wired.connectivity.close();
        await wired.engine.dispose();
      });
    });

    group('start/stop', () {
      test('start is idempotent and stop tears down listeners + timers', () {
        fakeAsync((async) {
          final mealPlan = _CountingAdapter('meal_plan');
          final shopping = _CountingAdapter('shopping_list');
          final wired = _build(mealPlan: mealPlan, shopping: shopping);

          wired.coordinator.start();
          wired.coordinator.start();
          wired.coordinator.start();

          wired.coordinator.enableShoppingListPolling();
          async.flushMicrotasks();
          expect(shopping.syncs, 1);

          wired.coordinator.stop();
          // After stop, polling timer is cancelled and connectivity events
          // are ignored.
          wired.connectivity.add([ConnectivityResult.none]);
          wired.connectivity.add([ConnectivityResult.wifi]);
          async.elapse(const Duration(seconds: 30));
          expect(shopping.syncs, 1, reason: 'no further syncs after stop');

          wired.connectivity.close();
          wired.engine.dispose();
        });
      });
    });

    group('connectivity gating', () {
      test('polling ticks while offline produce zero engine calls', () {
        fakeAsync((async) {
          var online = false;
          final shopping = _CountingAdapter('shopping_list');
          final mealPlan = _CountingAdapter('meal_plan');
          final wired = _build(
            mealPlan: mealPlan,
            shopping: shopping,
            isOnline: () => online,
          );

          wired.coordinator.enableShoppingListPolling();
          wired.coordinator.enableMealPlanPolling(DateTime(2026, 4, 1));
          async.elapse(const Duration(seconds: 30));

          expect(shopping.syncs, 0,
              reason: 'shopping ticks gated while offline');
          expect(mealPlan.syncs, 0,
              reason: 'meal plan ticks gated while offline');

          wired.coordinator.disableShoppingListPolling();
          wired.coordinator.disableMealPlanPolling();
          wired.coordinator.stop();
          wired.connectivity.close();
          wired.engine.dispose();
        });
      });

      test(
          'flipping isOnline to true alone does not trigger sync — '
          'only the connectivity-restore branch does', () {
        fakeAsync((async) {
          var online = false;
          final shopping = _CountingAdapter('shopping_list');
          final mealPlan = _CountingAdapter('meal_plan');
          final wired = _build(
            mealPlan: mealPlan,
            shopping: shopping,
            isOnline: () => online,
          );

          wired.coordinator.enableShoppingListPolling();
          async.flushMicrotasks();
          expect(shopping.syncs, 0, reason: 'immediate fire gated');

          // Gate opens, but no connectivity event has fired — passive flip
          // alone must not trigger anything.
          online = true;
          async.flushMicrotasks();
          expect(shopping.syncs, 0);

          wired.coordinator.disableShoppingListPolling();
          wired.coordinator.stop();
          wired.connectivity.close();
          wired.engine.dispose();
        });
      });

      test(
          'connectivity-restore branch fires even when isOnline gate '
          'still reads false (stream lag)', () {
        fakeAsync((async) {
          // Gate stays false the entire test — simulates the cold-start
          // window where isOnlineProvider has not yet emitted.
          final shopping = _CountingAdapter('shopping_list');
          final mealPlan = _CountingAdapter('meal_plan');
          final wired = _build(
            mealPlan: mealPlan,
            shopping: shopping,
            isOnline: () => false,
          );

          wired.coordinator.start();
          wired.coordinator.enableShoppingListPolling();
          async.flushMicrotasks();
          expect(shopping.syncs, 0, reason: 'immediate fire gated');

          // Offline → online edge through the coordinator's own stream.
          wired.connectivity.add([ConnectivityResult.none]);
          async.flushMicrotasks();
          wired.connectivity.add([ConnectivityResult.wifi]);
          async.flushMicrotasks();

          expect(shopping.syncs, 1,
              reason: 'restore branch bypasses the gate');

          wired.coordinator.disableShoppingListPolling();
          wired.coordinator.stop();
          wired.connectivity.close();
          wired.engine.dispose();
        });
      });
    });

    group('lifecycle', () {
      testWidgets('paused and resumed both sync open features',
          (tester) async {
        final mealPlan = _CountingAdapter('meal_plan');
        final shopping = _CountingAdapter('shopping_list');
        final wired = _build(mealPlan: mealPlan, shopping: shopping);

        wired.coordinator.start();
        wired.coordinator.enableShoppingListPolling();
        await tester.pump();
        final baseline = shopping.syncs;

        // Drive the lifecycle observer directly. The coordinator listens via
        // WidgetsBindingObserver, which the test binding routes through
        // handleAppLifecycleStateChanged.
        WidgetsBinding.instance
            .handleAppLifecycleStateChanged(AppLifecycleState.paused);
        WidgetsBinding.instance
            .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();

        expect(shopping.syncs, greaterThan(baseline),
            reason: 'open shopping page synced on paused/resumed');
        expect(mealPlan.syncs, 0,
            reason: 'closed meal plan page not touched');

        // stop() cancels timers directly — no extra flush triggered here.
        wired.coordinator.stop();
        await tester.pump(); // drain any in-flight sync futures before dispose
        await wired.connectivity.close();
        await wired.engine.dispose();
      });
    });
  });
}
