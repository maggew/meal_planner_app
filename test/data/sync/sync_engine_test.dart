import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/sync/sync_adapter.dart';
import 'package:meal_planner/data/sync/sync_engine.dart';
import 'package:meal_planner/data/sync/sync_types.dart';

class _InMemoryMeta implements SyncMetaStore {
  final Map<String, DateTime> _store = {};
  String _k(String f, String s) => '$f:$s';
  @override
  Future<DateTime?> getLastPulledAt(String f, String s) async => _store[_k(f, s)];
  @override
  Future<void> setLastPulledAt(String f, String s, DateTime at) async {
    _store[_k(f, s)] = at;
  }
}

class _FakeAdapter implements SyncAdapter {
  _FakeAdapter({
    List<PendingChange> pending = const [],
    Set<String> localPending = const {},
    List<RemoteRow> remote = const [],
    this.failPushIds = const {},
    this.pushErrors = const {},
    this.throwOnPull = false,
    this.pullError,
  })  : _pending = List.of(pending),
        _localPending = Set.of(localPending),
        _remote = List.of(remote);

  @override
  String get featureKey => 'fake';

  final List<PendingChange> _pending;
  final Set<String> _localPending;
  final List<RemoteRow> _remote;
  final Set<String> failPushIds;
  final Map<String, Object> pushErrors;
  final bool throwOnPull;
  final Object? pullError;

  final List<String> pushed = [];
  final List<String> markedSynced = [];
  final List<MapEntry<String, Object>> markedFailed = [];
  final List<List<RemoteRow>> applied = [];
  final List<DateTime?> pullCalls = [];

  @override
  Future<List<PendingChange>> readPending() async => List.of(_pending);

  @override
  Future<Set<String>> localPendingIds() async => Set.of(_localPending);

  @override
  Future<void> markSynced(String id) async => markedSynced.add(id);

  @override
  Future<void> markFailed(String id, Object error) async =>
      markedFailed.add(MapEntry(id, error));

  @override
  Future<void> applyRemote(List<RemoteRow> rows) async => applied.add(rows);

  @override
  Future<void> pushOne(PendingChange change) async {
    final custom = pushErrors[change.id];
    if (custom != null) throw custom;
    if (failPushIds.contains(change.id)) {
      throw StateError('boom: ${change.id}');
    }
    pushed.add(change.id);
  }

  @override
  Future<List<RemoteRow>> pullSince(DateTime? since, SyncScope scope) async {
    pullCalls.add(since);
    if (pullError != null) throw pullError!;
    if (throwOnPull) throw StateError('pull failed');
    return List.of(_remote);
  }
}

PendingChange _pc(String id, {SyncItemStatus status = SyncItemStatus.pending}) =>
    PendingChange(id: id, status: status, retryCount: 0, payload: const {});

RemoteRow _rr(String id) => RemoteRow(
      id: id,
      updatedAt: DateTime(2026, 4, 1),
      deleted: false,
      data: const {},
    );

void main() {
  group('SyncEngine', () {
    late SyncEngine engine;
    late _InMemoryMeta meta;

    setUp(() {
      meta = _InMemoryMeta();
      engine = SyncEngine(meta);
    });

    tearDown(() => engine.dispose());

    test('pushes pending then pulls and applies remote', () async {
      final adapter = _FakeAdapter(
        pending: [_pc('a'), _pc('b')],
        remote: [_rr('x'), _rr('y')],
      );

      final res = await engine.sync(adapter, const FullScope());

      expect(adapter.pushed, ['a', 'b']);
      expect(adapter.markedSynced, ['a', 'b']);
      expect(adapter.applied.single.map((r) => r.id), ['x', 'y']);
      expect(res.pushed, 2);
      expect(res.pulled, 2);
      expect(res.failed, 0);
      expect(res.ok, isTrue);
    });

    test('per-item push failure marks failed and continues', () async {
      final adapter = _FakeAdapter(
        pending: [_pc('a'), _pc('b'), _pc('c')],
        failPushIds: {'b'},
      );

      final res = await engine.sync(adapter, const FullScope());

      expect(adapter.pushed, ['a', 'c']);
      expect(adapter.markedSynced, ['a', 'c']);
      expect(adapter.markedFailed.single.key, 'b');
      expect(res.pushed, 2);
      expect(res.failed, 1);
      expect(res.errors.single.itemId, 'b');
      expect(res.errors.single.kind, SyncErrorKind.permanent);
      expect(res.ok, isFalse);
      expect(res.fatalError, isNull);
    });

    test(
        'transient push error leaves row pending — no markFailed, '
        'no failed count, kind=transient', () async {
      final adapter = _FakeAdapter(
        pending: [_pc('a'), _pc('b'), _pc('c')],
        pushErrors: {'b': const SocketException('offline')},
      );

      final res = await engine.sync(adapter, const FullScope());

      expect(adapter.pushed, ['a', 'c'], reason: 'a and c still synced');
      expect(adapter.markedSynced, ['a', 'c']);
      expect(adapter.markedFailed, isEmpty,
          reason: 'transient must NOT mark failed');
      expect(res.failed, 0,
          reason: 'transient must NOT contribute to failed count');
      expect(res.pushed, 2);
      expect(res.errors.single.itemId, 'b');
      expect(res.errors.single.kind, SyncErrorKind.transient);
      // Run completes (pull still runs) — no fatal error.
      expect(res.fatalError, isNull);
      expect(res.transientPullError, isNull);
    });

    test('TimeoutException on push is transient', () async {
      final adapter = _FakeAdapter(
        pending: [_pc('a')],
        pushErrors: {'a': TimeoutException('slow')},
      );
      final res = await engine.sync(adapter, const FullScope());
      expect(adapter.markedFailed, isEmpty);
      expect(res.failed, 0);
      expect(res.errors.single.kind, SyncErrorKind.transient);
    });

    test(
        'transient pull error sets transientPullError, NOT fatalError, '
        'and emits finished (not failed)', () async {
      final adapter = _FakeAdapter(
        pullError: const SocketException('offline'),
      );
      final events = <SyncEvent>[];
      final sub = engine.events.listen(events.add);

      final res = await engine.sync(adapter, const FullScope());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(res.fatalError, isNull);
      expect(res.transientPullError, isNotNull);
      expect(res.ok, isFalse,
          reason: 'still not "ok" — status provider can degrade');
      expect(events.map((e) => e.phase),
          containsAllInOrder([SyncPhase.started, SyncPhase.finished]));
      expect(events.map((e) => e.phase), isNot(contains(SyncPhase.failed)));
    });

    test('local-pending-wins: filters remote rows whose id is locally pending',
        () async {
      final adapter = _FakeAdapter(
        localPending: {'x'},
        remote: [_rr('x'), _rr('y'), _rr('z')],
      );

      await engine.sync(adapter, const FullScope());

      expect(adapter.applied.single.map((r) => r.id), ['y', 'z']);
    });

    test('persists lastPulledAt and uses it as cursor on next run', () async {
      final adapter = _FakeAdapter();

      await engine.sync(adapter, const FullScope());
      expect(adapter.pullCalls.single, isNull);
      final stored = await meta.getLastPulledAt('fake', 'all');
      expect(stored, isNotNull);

      await engine.sync(adapter, const FullScope());
      expect(adapter.pullCalls.last, stored);
    });

    test('pull error sets fatalError and emits failed event', () async {
      final adapter = _FakeAdapter(throwOnPull: true);
      final events = <SyncEvent>[];
      final sub = engine.events.listen(events.add);

      final res = await engine.sync(adapter, const FullScope());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(res.fatalError, isNotNull);
      expect(res.ok, isFalse);
      expect(events.map((e) => e.phase), contains(SyncPhase.failed));
    });

    test('does not skip rows when localPendingIds is empty', () async {
      final adapter = _FakeAdapter(remote: [_rr('x')]);
      await engine.sync(adapter, const FullScope());
      expect(adapter.applied.single.single.id, 'x');
    });

    test('skips applyRemote when nothing to apply', () async {
      final adapter = _FakeAdapter();
      await engine.sync(adapter, const FullScope());
      expect(adapter.applied, isEmpty);
    });

    test('reentrancy: concurrent calls for same scope share one run',
        () async {
      final adapter = _FakeAdapter(pending: [_pc('a')]);
      final f1 = engine.sync(adapter, const FullScope());
      final f2 = engine.sync(adapter, const FullScope());
      final results = await Future.wait([f1, f2]);
      expect(identical(results[0], results[1]), isTrue);
      expect(adapter.pushed, ['a']); // pushed only once
    });

    test('different scopes for same feature run independently', () async {
      final adapter = _FakeAdapter();
      await engine.sync(adapter, const MonthScope(2026, 3));
      await engine.sync(adapter, const MonthScope(2026, 4));
      expect(await meta.getLastPulledAt('fake', '2026-03'), isNotNull);
      expect(await meta.getLastPulledAt('fake', '2026-04'), isNotNull);
    });

    test('emits started and finished events on success', () async {
      final adapter = _FakeAdapter();
      final events = <SyncEvent>[];
      final sub = engine.events.listen(events.add);
      await engine.sync(adapter, const FullScope());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(events.map((e) => e.phase),
          containsAllInOrder([SyncPhase.started, SyncPhase.finished]));
    });
  });

  group('SyncScope', () {
    test('FullScope key is "all"', () {
      expect(const FullScope().key, 'all');
    });
    test('MonthScope key is zero-padded yyyy-MM', () {
      expect(const MonthScope(2026, 4).key, '2026-04');
      expect(const MonthScope(2026, 12).key, '2026-12');
    });
  });
}
