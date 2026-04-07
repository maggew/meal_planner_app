import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/meal_plan_dao.dart';
import 'package:meal_planner/data/sync/meal_plan_sync_adapter.dart';
import 'package:meal_planner/data/sync/sync_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class _MockDao extends Mock implements MealPlanDao {}

class _MockSupabase extends Mock implements SupabaseClient {}

LocalMealPlanEntry _row({
  required String localId,
  String? remoteId,
  String groupId = 'g1',
  String recipeId = 'r1',
  String? customName,
  String date = '2026-04-15',
  String mealType = 'lunch',
  String? cookIdsJson,
  String syncStatus = 'pendingCreate',
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
      updatedAt: DateTime(2026, 4, 1, 12),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(<LocalMealPlanEntriesCompanion>[]);
  });

  late _MockDao dao;
  late _MockSupabase supabase;
  late MealPlanSyncAdapter adapter;

  setUp(() {
    dao = _MockDao();
    supabase = _MockSupabase();
    adapter = MealPlanSyncAdapter(
      dao: dao,
      supabase: supabase,
      groupId: 'g1',
    );
  });

  group('readPending', () {
    test('maps non-delete rows to status pending', () async {
      when(() => dao.getPendingEntries('g1')).thenAnswer((_) async => [
            _row(localId: 'a', syncStatus: 'pendingCreate'),
            _row(localId: 'b', syncStatus: 'pendingUpdate'),
            _row(localId: 'c', syncStatus: 'failed'),
          ]);

      final res = await adapter.readPending();

      expect(res.map((c) => c.id).toList(), ['a', 'b', 'c']);
      expect(
          res.map((c) => c.status).toList(),
          everyElement(SyncItemStatus.pending));
    });

    test('maps pendingDelete rows to status pendingDelete', () async {
      when(() => dao.getPendingEntries('g1')).thenAnswer((_) async => [
            _row(localId: 'd', syncStatus: 'pendingDelete', remoteId: 'rd'),
          ]);

      final res = await adapter.readPending();

      expect(res.single.status, SyncItemStatus.pendingDelete);
    });
  });

  test('localPendingIds delegates to DAO', () async {
    when(() => dao.getPendingRemoteIds('g1'))
        .thenAnswer((_) async => {'r1', 'r2'});
    expect(await adapter.localPendingIds(), {'r1', 'r2'});
  });

  group('markSynced', () {
    test('hard-deletes when row is pendingDelete', () async {
      when(() => dao.getEntryByLocalId('x')).thenAnswer((_) async =>
          _row(localId: 'x', syncStatus: 'pendingDelete', remoteId: 'rx'));
      when(() => dao.hardDeleteEntry('x')).thenAnswer((_) async {});

      await adapter.markSynced('x');

      verify(() => dao.hardDeleteEntry('x')).called(1);
      verifyNever(() => dao.updateSyncStatus(any(), any()));
    });

    test('updates status to synced for non-delete rows', () async {
      when(() => dao.getEntryByLocalId('x')).thenAnswer(
          (_) async => _row(localId: 'x', syncStatus: 'pendingUpdate'));
      when(() => dao.updateSyncStatus(any(), any())).thenAnswer((_) async {});

      await adapter.markSynced('x');

      verify(() => dao.updateSyncStatus('x', 'synced')).called(1);
      verifyNever(() => dao.hardDeleteEntry(any()));
    });

    test('no-op when row missing', () async {
      when(() => dao.getEntryByLocalId('x')).thenAnswer((_) async => null);
      await adapter.markSynced('x');
      verifyNever(() => dao.updateSyncStatus(any(), any()));
      verifyNever(() => dao.hardDeleteEntry(any()));
    });
  });

  test('markFailed sets status to failed', () async {
    when(() => dao.updateSyncStatus(any(), any())).thenAnswer((_) async {});
    await adapter.markFailed('x', StateError('boom'));
    verify(() => dao.updateSyncStatus('x', 'failed')).called(1);
  });

  test('featureKey is meal_plan', () {
    expect(adapter.featureKey, 'meal_plan');
  });

  test('pullSince rejects non-MonthScope', () async {
    expect(
      () => adapter.pullSince(null, const FullScope()),
      throwsArgumentError,
    );
  });

  group('applyRemote (without prior pullSince)', () {
    test('is a no-op when month key is not stashed', () async {
      // Calling applyRemote without a preceding pullSince in the same run
      // should not touch the DAO (defensive — engine always pulls first).
      await adapter.applyRemote([
        RemoteRow(
            id: 'r',
            updatedAt: DateTime(2026),
            deleted: false,
            data: const {}),
      ]);
      verifyNever(() => dao.replaceAllSynced(any(), any(), any()));
    });
  });

  group('applyRemote (after pullSince stashes month)', () {
    test('builds synced companions and calls replaceAllSynced for the month',
        () async {
      adapter.debugSetPendingMonthKey('2026-04');

      final captured = <List<LocalMealPlanEntriesCompanion>>[];
      when(() => dao.replaceAllSynced(any(), any(), any()))
          .thenAnswer((inv) async {
        captured.add(inv.positionalArguments[2]
            as List<LocalMealPlanEntriesCompanion>);
      });

      await adapter.applyRemote([
        RemoteRow(
          id: 'remote-1',
          updatedAt: DateTime(2026, 4, 15, 9),
          deleted: false,
          data: const {
            'id': 'remote-1',
            'group_id': 'g1',
            'recipe_id': 'r1',
            'custom_name': null,
            'date': '2026-04-15',
            'meal_type': 'lunch',
            'cook_ids': ['u1', 'u2'],
            'updated_at': '2026-04-15T09:00:00.000Z',
          },
        ),
        RemoteRow(
          id: 'remote-2',
          updatedAt: DateTime(2026, 4, 16, 9),
          deleted: false,
          data: const {
            'id': 'remote-2',
            'group_id': 'g1',
            'recipe_id': null,
            'custom_name': 'Pizza',
            'date': '2026-04-16',
            'meal_type': 'dinner',
            'cook_ids': null,
            'updated_at': '2026-04-16T09:00:00.000Z',
          },
        ),
      ]);

      verify(() => dao.replaceAllSynced('g1', '2026-04', any())).called(1);
      expect(captured.single.length, 2);

      final c1 = captured.single[0];
      expect(c1.localId, const Value('remote-1'));
      expect(c1.remoteId, const Value('remote-1'));
      expect(c1.recipeId, const Value('r1'));
      expect(c1.customName, const Value<String?>(null));
      expect(c1.cookIdsJson.value, '["u1","u2"]');
      expect(c1.syncStatus, const Value('synced'));

      final c2 = captured.single[1];
      expect(c2.recipeId, const Value('')); // null → '' for free-text
      expect(c2.customName, const Value<String?>('Pizza'));
      expect(c2.cookIdsJson.value, isNull); // null cook_ids stays null
      expect(c2.mealType, const Value('dinner'));
    });

    test('clears the stashed month key after applying', () async {
      adapter.debugSetPendingMonthKey('2026-04');
      when(() => dao.replaceAllSynced(any(), any(), any()))
          .thenAnswer((_) async {});
      await adapter.applyRemote(const []);
      verify(() => dao.replaceAllSynced(any(), any(), any())).called(1);

      // A second call without re-stashing must be a no-op.
      await adapter.applyRemote(const []);
      verifyNoMoreInteractions(dao);
    });
  });
}
