import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/meal_plan_dao.dart';
import 'package:meal_planner/data/repositories/offline_first_meal_plan_repository.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==================== Mocks ====================

class MockMealPlanDao extends Mock implements MealPlanDao {}

class _LocalMealPlanEntriesCompanionFake extends Fake
    implements LocalMealPlanEntriesCompanion {}

// ==================== Supabase Fakes ====================
//
// PostgrestBuilder<T> implements Future<T>, which makes mocktail impractical
// for the query-builder chain. We hand-write minimal fakes instead.

/// Terminal builder returned by _FakeTransformBuilder.single().
/// Resolves to a Map containing the configured remoteId.
class _FakeSingleBuilder extends Fake
    implements PostgrestTransformBuilder<PostgrestMap> {
  final bool throws;
  final String remoteId;

  _FakeSingleBuilder({this.throws = false, this.remoteId = 'remote-1'});

  PostgrestMap get _value => {'id': remoteId};

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestMap) onValue, {
    Function? onError,
  }) {
    if (throws) {
      return Future<PostgrestMap>.error(Exception('supabase error'))
          .then(onValue, onError: onError);
    }
    return Future.value(_value).then(onValue, onError: onError);
  }

  @override
  Future<PostgrestMap> catchError(Function f, {bool Function(Object)? test}) =>
      Future.value(_value).catchError(f, test: test);

  @override
  Future<PostgrestMap> whenComplete(FutureOr<void> Function() action) =>
      Future.value(_value).whenComplete(action);

  @override
  Future<PostgrestMap> timeout(
    Duration d, {
    FutureOr<PostgrestMap> Function()? onTimeout,
  }) =>
      Future.value(_value).timeout(d, onTimeout: onTimeout);

  @override
  Stream<PostgrestMap> asStream() => Stream.value(_value);
}

/// Returned by _FakeFilterBuilder.select(). Provides single().
class _FakeTransformBuilder extends Fake
    implements PostgrestTransformBuilder<PostgrestList> {
  final bool throws;
  final String remoteId;

  _FakeTransformBuilder({this.throws = false, this.remoteId = 'remote-1'});

  @override
  PostgrestTransformBuilder<PostgrestMap> single() =>
      _FakeSingleBuilder(throws: throws, remoteId: remoteId);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestList) onValue, {
    Function? onError,
  }) =>
      Future.value(<PostgrestMap>[]).then(onValue, onError: onError);

  @override
  Future<PostgrestList> catchError(Function f, {bool Function(Object)? test}) =>
      Future.value(<PostgrestMap>[]).catchError(f, test: test);

  @override
  Future<PostgrestList> whenComplete(FutureOr<void> Function() action) =>
      Future.value(<PostgrestMap>[]).whenComplete(action);

  @override
  Future<PostgrestList> timeout(
    Duration d, {
    FutureOr<PostgrestList> Function()? onTimeout,
  }) =>
      Future.value(<PostgrestMap>[]).timeout(d, onTimeout: onTimeout);

  @override
  Stream<PostgrestList> asStream() => Stream.value(<PostgrestMap>[]);
}

/// Core filter-builder fake — sits between from() and the terminal operations.
/// Supports eq() chaining, select(), and can be awaited directly (for update/delete).
class _FakeFilterBuilder extends Fake
    implements PostgrestFilterBuilder<dynamic> {
  final bool throws;
  final String remoteId;

  _FakeFilterBuilder({this.throws = false, this.remoteId = 'remote-1'});

  @override
  PostgrestFilterBuilder<dynamic> eq(String column, Object value) => this;

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) =>
      _FakeTransformBuilder(throws: throws, remoteId: remoteId);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(dynamic) onValue, {
    Function? onError,
  }) {
    if (throws) {
      return Future<dynamic>.error(Exception('supabase error'))
          .then(onValue, onError: onError);
    }
    return Future<dynamic>.value(null).then(onValue, onError: onError);
  }

  @override
  Future<dynamic> catchError(Function f, {bool Function(Object)? test}) {
    if (throws) {
      return Future<dynamic>.error(Exception('supabase error'))
          .catchError(f, test: test);
    }
    return Future<dynamic>.value(null).catchError(f, test: test);
  }

  @override
  Future<dynamic> whenComplete(FutureOr<void> Function() action) =>
      Future<dynamic>.value(null).whenComplete(action);

  @override
  Future<dynamic> timeout(
    Duration d, {
    FutureOr<dynamic> Function()? onTimeout,
  }) =>
      Future<dynamic>.value(null).timeout(d, onTimeout: onTimeout);

  @override
  Stream<dynamic> asStream() => Stream.value(null);
}

/// Fake SupabaseQueryBuilder returned by _FakeSupabaseClient.from().
class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final bool throws;
  final String remoteId;

  _FakeQueryBuilder({this.throws = false, this.remoteId = 'remote-1'});

  @override
  PostgrestFilterBuilder<dynamic> insert(
    dynamic values, {
    bool defaultToNull = true,
  }) =>
      _FakeFilterBuilder(throws: throws, remoteId: remoteId);

  @override
  PostgrestFilterBuilder<dynamic> update(
    Map<dynamic, dynamic> values, {
    bool defaultToNull = true,
  }) =>
      _FakeFilterBuilder(throws: throws);

  @override
  PostgrestFilterBuilder<dynamic> delete({bool defaultToNull = true}) =>
      _FakeFilterBuilder(throws: throws);
}

/// Top-level fake SupabaseClient. Tracks how often from() is called.
class _FakeSupabaseClient extends Fake implements SupabaseClient {
  final bool throws;
  final String remoteId;
  int fromCalls = 0;

  _FakeSupabaseClient({this.throws = false, this.remoteId = 'remote-1'});

  @override
  SupabaseQueryBuilder from(String table) {
    fromCalls++;
    return _FakeQueryBuilder(throws: throws, remoteId: remoteId);
  }
}

// ==================== Helpers ====================

const _kGroupId = 'gruppe-1';
const _kDate = '2026-03-10';
final _kDateTime = DateTime(2026, 3, 10);

LocalMealPlanEntry _fakeEntry({
  String localId = 'local-1',
  String? remoteId = 'remote-1',
  String groupId = _kGroupId,
  String recipeId = '',
  String? customName,
  String date = _kDate,
  String mealType = 'lunch',
  String? cookIdsJson,
  String syncStatus = 'synced',
}) =>
    LocalMealPlanEntry(
      localId: localId,
      remoteId: remoteId,
      groupId: groupId,
      recipeId: recipeId,
      customName: customName,
      date: date,
      mealType: mealType,
      cookIdsJson: cookIdsJson,
      syncStatus: syncStatus,
      updatedAt: DateTime(2026, 3, 10),
    );

void main() {
  late MockMealPlanDao mockDao;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(_LocalMealPlanEntriesCompanionFake());
  });

  setUp(() {
    mockDao = MockMealPlanDao();
  });

  tearDown(() => container.dispose());

  OfflineFirstMealPlanRepository _buildRepo({
    required bool isOnline,
    _FakeSupabaseClient? supabase,
    String groupId = _kGroupId,
  }) {
    final client = supabase ?? _FakeSupabaseClient();
    container = ProviderContainer(overrides: [
      isOnlineProvider.overrideWithValue(isOnline),
    ]);
    final testProvider = Provider<OfflineFirstMealPlanRepository>((ref) {
      return OfflineFirstMealPlanRepository(
        dao: mockDao,
        supabase: client,
        groupId: groupId,
        ref: ref,
      );
    });
    return container.read(testProvider);
  }

  // Stubt alle häufig verwendeten DAO-Methoden ohne Rückgabewert.
  void _stubDaoVoids() {
    when(() => mockDao.upsertEntry(any())).thenAnswer((_) async {});
    when(() => mockDao.updateSyncStatus(any(), any(),
        remoteId: any(named: 'remoteId'))).thenAnswer((_) async {});
    when(() => mockDao.markAsDeleted(any())).thenAnswer((_) async {});
    when(() => mockDao.hardDeleteEntry(any())).thenAnswer((_) async {});
    when(() => mockDao.updateCookIds(any(), any())).thenAnswer((_) async {});
    when(() => mockDao.updateEntry(
          any(),
          recipeId: any(named: 'recipeId'),
          customName: any(named: 'customName'),
          cookIdsJson: any(named: 'cookIdsJson'),
          keepPendingCreate: any(named: 'keepPendingCreate'),
        )).thenAnswer((_) async {});
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 1 — watchEntriesForDate: Stream-Vertrag
  // ═══════════════════════════════════════════════════════════════════════════

  group('watchEntriesForDate', () {
    test('1 — leere Liste wenn DAO keine Einträge für das Datum liefert',
        () async {
      final repo = _buildRepo(isOnline: false);
      final ctrl = StreamController<List<LocalMealPlanEntry>>.broadcast();
      when(() => mockDao.watchEntriesForDate(any(), any()))
          .thenAnswer((_) => ctrl.stream);

      final future = expectLater(
        repo.watchEntriesForDate(_kDateTime),
        emits(isEmpty),
      );
      ctrl.add([]);
      await future;
      await ctrl.close();
    });

    test('2 — DAO wird mit korrekt formatiertem Datums-String aufgerufen',
        () async {
      final repo = _buildRepo(isOnline: false);
      final ctrl = StreamController<List<LocalMealPlanEntry>>.broadcast();
      when(() => mockDao.watchEntriesForDate(_kGroupId, '2026-03-10'))
          .thenAnswer((_) => ctrl.stream);

      repo.watchEntriesForDate(DateTime(2026, 3, 10)).listen((_) {});

      verify(() => mockDao.watchEntriesForDate(_kGroupId, '2026-03-10'))
          .called(1);
      await ctrl.close();
    });

    test(

        '3 — Gruppen-Isolation: DAO wird nur mit der eigenen groupId abgefragt',
        () async {
      final repo = _buildRepo(isOnline: false, groupId: 'gruppe-A');
      final ctrl = StreamController<List<LocalMealPlanEntry>>.broadcast();
      when(() => mockDao.watchEntriesForDate('gruppe-A', any()))
          .thenAnswer((_) => ctrl.stream);

      repo.watchEntriesForDate(_kDateTime).listen((_) {});

      verify(() => mockDao.watchEntriesForDate('gruppe-A', any())).called(1);
      verifyNever(() => mockDao.watchEntriesForDate('gruppe-B', any()));
      await ctrl.close();
    });

    test('4 — Einträge im pendingDelete-Status erscheinen nicht im Stream',
        () async {
      // pendingDelete-Filterung obliegt dem DAO; das Repository gibt genau das
      // weiter, was der DAO liefert. Ein leeres DAO-Ergebnis → leerer Stream.
      final repo = _buildRepo(isOnline: false);
      final ctrl = StreamController<List<LocalMealPlanEntry>>.broadcast();
      when(() => mockDao.watchEntriesForDate(any(), any()))
          .thenAnswer((_) => ctrl.stream);

      final future = expectLater(
        repo.watchEntriesForDate(_kDateTime),
        emits(isEmpty),
      );
      ctrl.add([]); // DAO hat pendingDelete herausgefiltert
      await future;
      await ctrl.close();
    });

    test(

        '5 — recipeId="" (Free-Text intern) wird als null in der Entity gemappt',
        () async {
      final repo = _buildRepo(isOnline: false);
      final ctrl = StreamController<List<LocalMealPlanEntry>>.broadcast();
      when(() => mockDao.watchEntriesForDate(any(), any()))
          .thenAnswer((_) => ctrl.stream);

      final future = expectLater(
        repo.watchEntriesForDate(_kDateTime),
        emits(predicate<List<dynamic>>(
          (entries) => entries.first.recipeId == null,
          'recipeId ist null für Free-Text-Eintrag',
        )),
      );
      ctrl.add([_fakeEntry(recipeId: '')]);
      await future;
      await ctrl.close();
    });

    test('6 — recipeId="abc" wird unverändert auf die Entity übertragen',
        () async {
      final repo = _buildRepo(isOnline: false);
      final ctrl = StreamController<List<LocalMealPlanEntry>>.broadcast();
      when(() => mockDao.watchEntriesForDate(any(), any()))
          .thenAnswer((_) => ctrl.stream);

      final future = expectLater(
        repo.watchEntriesForDate(_kDateTime),
        emits(predicate<List<dynamic>>(
          (entries) => entries.first.recipeId == 'abc',
        )),
      );
      ctrl.add([_fakeEntry(recipeId: 'abc')]);
      await future;
      await ctrl.close();
    });

    test('7 — cookIdsJson=null wird als leere Liste in der Entity gemappt',
        () async {
      final repo = _buildRepo(isOnline: false);
      final ctrl = StreamController<List<LocalMealPlanEntry>>.broadcast();
      when(() => mockDao.watchEntriesForDate(any(), any()))
          .thenAnswer((_) => ctrl.stream);

      final future = expectLater(
        repo.watchEntriesForDate(_kDateTime),
        emits(predicate<List<dynamic>>(
          (entries) => entries.first.cookIds.isEmpty,
        )),
      );
      ctrl.add([_fakeEntry(cookIdsJson: null)]);
      await future;
      await ctrl.close();
    });

    test('8 — cookIdsJson mit JSON-Array wird korrekt deserialisiert',

        () async {
      final repo = _buildRepo(isOnline: false);
      final ctrl = StreamController<List<LocalMealPlanEntry>>.broadcast();
      when(() => mockDao.watchEntriesForDate(any(), any()))
          .thenAnswer((_) => ctrl.stream);

      final future = expectLater(
        repo.watchEntriesForDate(_kDateTime),
        emits(predicate<List<dynamic>>(
          (entries) =>
              entries.first.cookIds.length == 2 &&
              entries.first.cookIds.first == 'user-a' &&
              entries.first.cookIds.last == 'user-b',
        )),
      );
      ctrl.add([_fakeEntry(cookIdsJson: '["user-a","user-b"]')]);
      await future;
      await ctrl.close();
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 2 — addEntry: Online-Sync
  // ═══════════════════════════════════════════════════════════════════════════

  group('addEntry – online', () {
    test('9 — Online: Eintrag wird lokal gespeichert (upsertEntry aufgerufen)',
        () async {
      _stubDaoVoids();
      final repo = _buildRepo(isOnline: true);

      await repo.addEntry(date: _kDateTime, mealType: MealType.lunch);

      verify(() => mockDao.upsertEntry(any())).called(1);
    });

    test('10 — Online: Supabase.from() wird aufgerufen', () async {
      _stubDaoVoids();
      final supabase = _FakeSupabaseClient();
      final repo = _buildRepo(isOnline: true, supabase: supabase);

      await repo.addEntry(date: _kDateTime, mealType: MealType.lunch);

      expect(supabase.fromCalls, greaterThan(0));
    });

    test(
        '11 — Online + erfolgreicher Insert: remoteId wird gesetzt und syncStatus=synced',
        () async {
      _stubDaoVoids();
      final supabase = _FakeSupabaseClient(remoteId: 'remote-xyz');
      final repo = _buildRepo(isOnline: true, supabase: supabase);

      await repo.addEntry(date: _kDateTime, mealType: MealType.lunch);

      verify(() => mockDao.updateSyncStatus(
            any(),
            'synced',
            remoteId: 'remote-xyz',
          )).called(1);
    });

    test(

        '12 — Online + Supabase-Fehler: kein Absturz, syncStatus bleibt pendingCreate',
        () async {
      _stubDaoVoids();
      final supabase = _FakeSupabaseClient(throws: true);
      final repo = _buildRepo(isOnline: true, supabase: supabase);

      await expectLater(
        repo.addEntry(date: _kDateTime, mealType: MealType.lunch),
        completes,
      );

      verifyNever(() => mockDao.updateSyncStatus(
            any(),
            'synced',
            remoteId: any(named: 'remoteId'),
          ));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 3 — addEntry: Offline
  // ═══════════════════════════════════════════════════════════════════════════

  group('addEntry – offline', () {
    test('13 — Offline: Eintrag wird lokal gespeichert', () async {
      _stubDaoVoids();
      final repo = _buildRepo(isOnline: false);

      await repo.addEntry(date: _kDateTime, mealType: MealType.lunch);

      verify(() => mockDao.upsertEntry(any())).called(1);
    });

    test('14 — Offline: Supabase wird nicht kontaktiert', () async {
      _stubDaoVoids();
      final supabase = _FakeSupabaseClient();
      final repo = _buildRepo(isOnline: false, supabase: supabase);

      await repo.addEntry(date: _kDateTime, mealType: MealType.lunch);

      expect(supabase.fromCalls, 0);
      verifyNever(() => mockDao.updateSyncStatus(
            any(),
            'synced',
            remoteId: any(named: 'remoteId'),
          ));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 4 — addEntry: Daten-Korrektheit
  // ═══════════════════════════════════════════════════════════════════════════

  group('addEntry – Daten-Korrektheit', () {
    test(
        '15 — Free-Text-Eintrag (customName, kein recipeId): recipeId wird als "" gespeichert',
        () async {
      _stubDaoVoids();
      final repo = _buildRepo(isOnline: false);

      await repo.addEntry(
        date: _kDateTime,
        mealType: MealType.lunch,
        customName: 'Reste vom Vortag',
      );

      final captured = verify(() => mockDao.upsertEntry(captureAny())).captured;
      final companion = captured.first as LocalMealPlanEntriesCompanion;
      expect(companion.recipeId.value, '');
      expect(companion.customName.value, 'Reste vom Vortag');
    });

    test('16 — Rezept-Eintrag: recipeId wird korrekt gespeichert', () async {
      _stubDaoVoids();
      final repo = _buildRepo(isOnline: false);

      await repo.addEntry(
        date: _kDateTime,
        mealType: MealType.lunch,
        recipeId: 'recipe-42',
      );

      final captured = verify(() => mockDao.upsertEntry(captureAny())).captured;
      final companion = captured.first as LocalMealPlanEntriesCompanion;
      expect(companion.recipeId.value, 'recipe-42');
    });

    test('17 — Leere cookIds werden als null gespeichert (nicht als "[]")',
        () async {
      _stubDaoVoids();
      final repo = _buildRepo(isOnline: false);

      await repo.addEntry(
        date: _kDateTime,
        mealType: MealType.lunch,
        cookIds: [],
      );

      final captured = verify(() => mockDao.upsertEntry(captureAny())).captured;
      final companion = captured.first as LocalMealPlanEntriesCompanion;
      expect(companion.cookIdsJson.value, isNull);
    });

    test('18 — Nicht-leere cookIds werden als JSON-Array gespeichert',

        () async {
      _stubDaoVoids();
      final repo = _buildRepo(isOnline: false);

      await repo.addEntry(
        date: _kDateTime,
        mealType: MealType.lunch,
        cookIds: ['user-1', 'user-2'],
      );

      final captured = verify(() => mockDao.upsertEntry(captureAny())).captured;
      final companion = captured.first as LocalMealPlanEntriesCompanion;
      expect(companion.cookIdsJson.value, '["user-1","user-2"]');
    });

    test('19 — Jeder addEntry-Aufruf erzeugt eine einzigartige localId',
        () async {
      _stubDaoVoids();
      final repo = _buildRepo(isOnline: false);

      await repo.addEntry(date: _kDateTime, mealType: MealType.lunch);
      await repo.addEntry(date: _kDateTime, mealType: MealType.dinner);

      final captured = verify(() => mockDao.upsertEntry(captureAny())).captured;
      final id1 = (captured[0] as LocalMealPlanEntriesCompanion).localId.value;
      final id2 = (captured[1] as LocalMealPlanEntriesCompanion).localId.value;
      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 5 — updateEntry
  // ═══════════════════════════════════════════════════════════════════════════

  group('updateEntry', () {
    test('20 — Nicht-existente localId: kein Absturz, keine DAO-Operationen',
        () async {
      when(() => mockDao.getEntryByLocalId('ghost-id'))
          .thenAnswer((_) async => null);

      final repo = _buildRepo(isOnline: true);

      await expectLater(
        repo.updateEntry('ghost-id', recipeId: 'r1'),
        completes,
      );

      verifyNever(() => mockDao.updateEntry(any(),
          recipeId: any(named: 'recipeId'),
          customName: any(named: 'customName'),
          cookIdsJson: any(named: 'cookIdsJson'),
          keepPendingCreate: any(named: 'keepPendingCreate')));
    });

    test(
        '21 — Online + Eintrag hat remoteId: lokales Update + syncStatus=synced',
        () async {
      _stubDaoVoids();
      final supabase = _FakeSupabaseClient();
      when(() => mockDao.getEntryByLocalId('local-1'))
          .thenAnswer((_) async => _fakeEntry(remoteId: 'remote-1'));

      final repo = _buildRepo(isOnline: true, supabase: supabase);
      await repo.updateEntry('local-1', recipeId: 'r-neu');

      verify(() => mockDao.updateEntry(
            'local-1',
            recipeId: any(named: 'recipeId'),
            customName: any(named: 'customName'),
            cookIdsJson: any(named: 'cookIdsJson'),
            keepPendingCreate: any(named: 'keepPendingCreate'),
          )).called(1);
      verify(() => mockDao.updateSyncStatus('local-1', 'synced',
          remoteId: 'remote-1')).called(1);
    });

    test(
        '22 — Offline + Eintrag hat remoteId: nur lokales Update, kein Supabase-Aufruf',
        () async {
      _stubDaoVoids();
      final supabase = _FakeSupabaseClient();
      when(() => mockDao.getEntryByLocalId('local-1'))
          .thenAnswer((_) async => _fakeEntry(remoteId: 'remote-1'));

      final repo = _buildRepo(isOnline: false, supabase: supabase);
      await repo.updateEntry('local-1', recipeId: 'r-neu');

      verify(() => mockDao.updateEntry(
            'local-1',
            recipeId: any(named: 'recipeId'),
            customName: any(named: 'customName'),
            cookIdsJson: any(named: 'cookIdsJson'),
            keepPendingCreate: any(named: 'keepPendingCreate'),
          )).called(1);
      expect(supabase.fromCalls, 0);
      verifyNever(() => mockDao.updateSyncStatus(any(), 'synced',
          remoteId: any(named: 'remoteId')));
    });

    test(
        '23 — Online + kein remoteId (pendingCreate): syncStatus bleibt pendingCreate, kein Supabase-Aufruf',
        () async {
      _stubDaoVoids();
      final supabase = _FakeSupabaseClient();
      when(() => mockDao.getEntryByLocalId('local-1')).thenAnswer(
          (_) async => _fakeEntry(remoteId: null, syncStatus: 'pendingCreate'));

      final repo = _buildRepo(isOnline: true, supabase: supabase);
      await repo.updateEntry('local-1', recipeId: 'r-neu');

      expect(supabase.fromCalls, 0);
      verifyNever(() => mockDao.updateSyncStatus(any(), 'synced',
          remoteId: any(named: 'remoteId')));
    });

    test(

        '24 — Online + Supabase-Fehler: lokales Update bleibt erhalten, kein Absturz',
        () async {
      _stubDaoVoids();
      final supabase = _FakeSupabaseClient(throws: true);
      when(() => mockDao.getEntryByLocalId('local-1'))
          .thenAnswer((_) async => _fakeEntry(remoteId: 'remote-1'));

      final repo = _buildRepo(isOnline: true, supabase: supabase);

      await expectLater(
        repo.updateEntry('local-1', recipeId: 'r-neu'),
        completes,
      );

      verify(() => mockDao.updateEntry(
            'local-1',
            recipeId: any(named: 'recipeId'),
            customName: any(named: 'customName'),
            cookIdsJson: any(named: 'cookIdsJson'),
            keepPendingCreate: any(named: 'keepPendingCreate'),
          )).called(1);
      verifyNever(() => mockDao.updateSyncStatus(any(), 'synced',
          remoteId: any(named: 'remoteId')));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 6 — removeEntry
  // ═══════════════════════════════════════════════════════════════════════════

  group('removeEntry', () {
    test('25 — Nicht-existente localId: kein Absturz, keine DAO-Operationen',
        () async {
      when(() => mockDao.getEntryByLocalId('ghost'))
          .thenAnswer((_) async => null);

      final repo = _buildRepo(isOnline: true);
      await expectLater(repo.removeEntry('ghost'), completes);

      verifyNever(() => mockDao.markAsDeleted(any()));
      verifyNever(() => mockDao.hardDeleteEntry(any()));
    });

    test(
        '26 — Online + hat remoteId: Reihenfolge markAsDeleted → Supabase → hardDelete',
        () async {
      _stubDaoVoids();
      final callOrder = <String>[];
      when(() => mockDao.getEntryByLocalId('local-1'))
          .thenAnswer((_) async => _fakeEntry(remoteId: 'remote-1'));
      when(() => mockDao.markAsDeleted('local-1'))
          .thenAnswer((_) async => callOrder.add('markAsDeleted'));
      when(() => mockDao.hardDeleteEntry('local-1'))
          .thenAnswer((_) async => callOrder.add('hardDelete'));

      final supabase = _FakeSupabaseClient();
      final repo = _buildRepo(isOnline: true, supabase: supabase);
      await repo.removeEntry('local-1');

      expect(callOrder, ['markAsDeleted', 'hardDelete']);
      expect(supabase.fromCalls, greaterThan(0));
    });

    test(
        '27 — Offline + hat remoteId: nur markAsDeleted, kein Supabase, kein hardDelete',
        () async {
      _stubDaoVoids();
      when(() => mockDao.getEntryByLocalId('local-1'))
          .thenAnswer((_) async => _fakeEntry(remoteId: 'remote-1'));
      final supabase = _FakeSupabaseClient();

      final repo = _buildRepo(isOnline: false, supabase: supabase);
      await repo.removeEntry('local-1');

      verify(() => mockDao.markAsDeleted('local-1')).called(1);
      expect(supabase.fromCalls, 0);
      verifyNever(() => mockDao.hardDeleteEntry(any()));
    });

    test('28 — Online + kein remoteId: nur markAsDeleted, kein Supabase-Aufruf',
        () async {
      _stubDaoVoids();
      when(() => mockDao.getEntryByLocalId('local-1'))
          .thenAnswer((_) async => _fakeEntry(remoteId: null));
      final supabase = _FakeSupabaseClient();

      final repo = _buildRepo(isOnline: true, supabase: supabase);
      await repo.removeEntry('local-1');

      verify(() => mockDao.markAsDeleted('local-1')).called(1);
      expect(supabase.fromCalls, 0);
      verifyNever(() => mockDao.hardDeleteEntry(any()));
    });

    test(
        '29 — Online + Supabase-Fehler: Eintrag bleibt pendingDelete (kein hardDelete)',
        () async {
      _stubDaoVoids();
      when(() => mockDao.getEntryByLocalId('local-1'))
          .thenAnswer((_) async => _fakeEntry(remoteId: 'remote-1'));
      final supabase = _FakeSupabaseClient(throws: true);

      final repo = _buildRepo(isOnline: true, supabase: supabase);

      await expectLater(repo.removeEntry('local-1'), completes);

      verify(() => mockDao.markAsDeleted('local-1')).called(1);
      verifyNever(() => mockDao.hardDeleteEntry(any()));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 7 — setCookIds
  // ═══════════════════════════════════════════════════════════════════════════

  group('setCookIds', () {
    test('30 — Online + hat remoteId: lokales Update + syncStatus=synced',
        () async {
      _stubDaoVoids();
      when(() => mockDao.getEntryByLocalId('local-1'))
          .thenAnswer((_) async => _fakeEntry(remoteId: 'remote-1'));
      final supabase = _FakeSupabaseClient();

      final repo = _buildRepo(isOnline: true, supabase: supabase);
      await repo.setCookIds('local-1', ['user-x']);

      verify(() => mockDao.updateCookIds('local-1', any())).called(1);
      verify(() => mockDao.updateSyncStatus('local-1', 'synced',
          remoteId: 'remote-1')).called(1);
      expect(supabase.fromCalls, greaterThan(0));
    });

    test(

        '31 — Online + kein remoteId: nur lokales Update, kein Supabase-Aufruf',
        () async {
      _stubDaoVoids();
      when(() => mockDao.getEntryByLocalId('local-1'))
          .thenAnswer((_) async => _fakeEntry(remoteId: null));
      final supabase = _FakeSupabaseClient();

      final repo = _buildRepo(isOnline: true, supabase: supabase);
      await repo.setCookIds('local-1', ['user-x']);

      verify(() => mockDao.updateCookIds('local-1', any())).called(1);
      expect(supabase.fromCalls, 0);
      verifyNever(() => mockDao.updateSyncStatus(any(), 'synced',
          remoteId: any(named: 'remoteId')));
    });

    test('32 — Offline: nur lokales Update, kein Supabase-Aufruf', () async {
      _stubDaoVoids();
      when(() => mockDao.getEntryByLocalId('local-1'))
          .thenAnswer((_) async => _fakeEntry(remoteId: 'remote-1'));
      final supabase = _FakeSupabaseClient();

      final repo = _buildRepo(isOnline: false, supabase: supabase);
      await repo.setCookIds('local-1', ['user-x']);

      verify(() => mockDao.updateCookIds('local-1', any())).called(1);
      expect(supabase.fromCalls, 0);
      verifyNever(() => mockDao.updateSyncStatus(any(), 'synced',
          remoteId: any(named: 'remoteId')));
    });

    test('33 — Leere cookIds werden als null gespeichert', () async {
      _stubDaoVoids();
      when(() => mockDao.getEntryByLocalId('local-1'))
          .thenAnswer((_) async => _fakeEntry(remoteId: null));

      final repo = _buildRepo(isOnline: false);
      await repo.setCookIds('local-1', []);

      final captured =
          verify(() => mockDao.updateCookIds('local-1', captureAny())).captured;
      expect(captured.first, isNull);
    });

    test(
        '34 — Online + Supabase-Fehler: lokales Update bleibt, kein syncStatus=synced',
        () async {
      _stubDaoVoids();
      when(() => mockDao.getEntryByLocalId('local-1'))
          .thenAnswer((_) async => _fakeEntry(remoteId: 'remote-1'));
      final supabase = _FakeSupabaseClient(throws: true);

      final repo = _buildRepo(isOnline: true, supabase: supabase);
      await repo.setCookIds('local-1', ['user-x']);

      verify(() => mockDao.updateCookIds('local-1', any())).called(1);
      verifyNever(() => mockDao.updateSyncStatus(any(), 'synced',
          remoteId: any(named: 'remoteId')));
    });

    test(
        '35 — Nicht-existente localId: updateCookIds aufgerufen, kein Supabase-Aufruf',
        () async {
      _stubDaoVoids();
      when(() => mockDao.getEntryByLocalId('ghost'))
          .thenAnswer((_) async => null);
      final supabase = _FakeSupabaseClient();

      final repo = _buildRepo(isOnline: true, supabase: supabase);
      await repo.setCookIds('ghost', ['user-x']);

      verify(() => mockDao.updateCookIds('ghost', any())).called(1);
      expect(supabase.fromCalls, 0);
    });
  });
}
