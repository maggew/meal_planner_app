import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/shopping_item_dao.dart';
import 'package:meal_planner/data/repositories/supabase_shopping_list_repository.dart';
import 'package:meal_planner/data/sync/shopping_list_sync_adapter.dart';
import 'package:meal_planner/data/sync/sync_types.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:mocktail/mocktail.dart';

class _MockDao extends Mock implements ShoppingItemDao {}

class _MockRemote extends Mock implements SupabaseShoppingListRepository {}

LocalShoppingItem _row({
  required String localId,
  String? remoteId,
  String groupId = 'g1',
  String information = 'Milch',
  String? quantity = '1L',
  bool isChecked = false,
  String syncStatus = 'pendingCreate',
}) =>
    LocalShoppingItem(
      localId: localId,
      remoteId: remoteId,
      groupId: groupId,
      information: information,
      quantity: quantity,
      isChecked: isChecked,
      syncStatus: syncStatus,
      updatedAt: DateTime(2026, 4, 1),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(<LocalShoppingItemsCompanion>[]);
  });

  late _MockDao dao;
  late _MockRemote remote;
  late ShoppingListSyncAdapter adapter;

  setUp(() {
    dao = _MockDao();
    remote = _MockRemote();
    adapter = ShoppingListSyncAdapter(
      dao: dao,
      remote: remote,
      groupId: 'g1',
    );
  });

  test('featureKey is shopping_list', () {
    expect(adapter.featureKey, 'shopping_list');
  });

  group('readPending', () {
    test('maps pendingCreate/Update/failed to pending', () async {
      when(() => dao.getPendingItems('g1')).thenAnswer((_) async => [
            _row(localId: 'a', syncStatus: 'pendingCreate'),
            _row(localId: 'b', syncStatus: 'pendingUpdate', remoteId: 'rb'),
            _row(localId: 'c', syncStatus: 'failed', remoteId: 'rc'),
          ]);
      final res = await adapter.readPending();
      expect(res.map((c) => c.id).toList(), ['a', 'b', 'c']);
      expect(res.map((c) => c.status),
          everyElement(SyncItemStatus.pending));
    });

    test('maps pendingDelete to pendingDelete', () async {
      when(() => dao.getPendingItems('g1')).thenAnswer((_) async => [
            _row(localId: 'd', syncStatus: 'pendingDelete', remoteId: 'rd'),
          ]);
      final res = await adapter.readPending();
      expect(res.single.status, SyncItemStatus.pendingDelete);
    });
  });

  test('localPendingIds delegates to DAO', () async {
    when(() => dao.getPendingRemoteIds('g1'))
        .thenAnswer((_) async => {'r1'});
    expect(await adapter.localPendingIds(), {'r1'});
  });

  group('markSynced', () {
    test('hard-deletes pendingDelete rows', () async {
      when(() => dao.getItemByLocalId('x')).thenAnswer((_) async =>
          _row(localId: 'x', syncStatus: 'pendingDelete', remoteId: 'rx'));
      when(() => dao.hardDeleteItem('x')).thenAnswer((_) async {});
      await adapter.markSynced('x');
      verify(() => dao.hardDeleteItem('x')).called(1);
      verifyNever(() => dao.updateSyncStatus(any(), any()));
    });

    test('updates other rows to synced', () async {
      when(() => dao.getItemByLocalId('x')).thenAnswer(
          (_) async => _row(localId: 'x', syncStatus: 'pendingUpdate'));
      when(() => dao.updateSyncStatus(any(), any())).thenAnswer((_) async {});
      await adapter.markSynced('x');
      verify(() => dao.updateSyncStatus('x', 'synced')).called(1);
    });

    test('no-op when row missing', () async {
      when(() => dao.getItemByLocalId('x')).thenAnswer((_) async => null);
      await adapter.markSynced('x');
      verifyNever(() => dao.updateSyncStatus(any(), any()));
      verifyNever(() => dao.hardDeleteItem(any()));
    });
  });

  test('markFailed sets failed status', () async {
    when(() => dao.updateSyncStatus(any(), any())).thenAnswer((_) async {});
    await adapter.markFailed('x', StateError('boom'));
    verify(() => dao.updateSyncStatus('x', 'failed')).called(1);
  });

  group('pushOne', () {
    test('pendingCreate calls remote.addItem and persists remoteId',
        () async {
      when(() => dao.getItemByLocalId('a')).thenAnswer(
          (_) async => _row(localId: 'a', syncStatus: 'pendingCreate'));
      when(() => remote.addItem('Milch', '1L')).thenAnswer((_) async =>
          const ShoppingListItem(
              id: 'remote-a',
              groupId: 'g1',
              information: 'Milch',
              quantity: '1L',
              isChecked: false));
      when(() => dao.updateSyncStatus(any(), any(), remoteId: any(named: 'remoteId')))
          .thenAnswer((_) async {});

      await adapter.pushOne(const PendingChange(
          id: 'a',
          status: SyncItemStatus.pending,
          retryCount: 0,
          payload: {}));

      verify(() => remote.addItem('Milch', '1L')).called(1);
      verifyNever(() => remote.toggleItem(any(), any()));
      verify(() => dao.updateSyncStatus('a', 'synced', remoteId: 'remote-a'))
          .called(1);
    });

    test('pendingCreate with isChecked=true also toggles after insert',
        () async {
      when(() => dao.getItemByLocalId('a')).thenAnswer((_) async => _row(
          localId: 'a', syncStatus: 'pendingCreate', isChecked: true));
      when(() => remote.addItem(any(), any())).thenAnswer((_) async =>
          const ShoppingListItem(
              id: 'remote-a',
              groupId: 'g1',
              information: 'Milch',
              quantity: '1L',
              isChecked: false));
      when(() => remote.toggleItem(any(), any())).thenAnswer((_) async {});
      when(() => dao.updateSyncStatus(any(), any(), remoteId: any(named: 'remoteId')))
          .thenAnswer((_) async {});

      await adapter.pushOne(const PendingChange(
          id: 'a',
          status: SyncItemStatus.pending,
          retryCount: 0,
          payload: {}));

      verify(() => remote.toggleItem('remote-a', true)).called(1);
    });

    test('pendingUpdate calls update + toggle on remote', () async {
      when(() => dao.getItemByLocalId('b')).thenAnswer((_) async => _row(
          localId: 'b',
          remoteId: 'rb',
          syncStatus: 'pendingUpdate',
          isChecked: true));
      when(() => remote.updateItem(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => remote.toggleItem(any(), any())).thenAnswer((_) async {});

      await adapter.pushOne(const PendingChange(
          id: 'b',
          status: SyncItemStatus.pending,
          retryCount: 0,
          payload: {}));

      verify(() => remote.updateItem('rb', 'Milch', '1L')).called(1);
      verify(() => remote.toggleItem('rb', true)).called(1);
    });

    test('pendingUpdate without remoteId falls back to addItem', () async {
      when(() => dao.getItemByLocalId('b')).thenAnswer((_) async =>
          _row(localId: 'b', syncStatus: 'pendingUpdate'));
      when(() => remote.addItem(any(), any())).thenAnswer((_) async =>
          const ShoppingListItem(
              id: 'remote-b',
              groupId: 'g1',
              information: 'Milch',
              quantity: '1L',
              isChecked: false));
      when(() => dao.updateSyncStatus(any(), any(),
          remoteId: any(named: 'remoteId'))).thenAnswer((_) async {});

      await adapter.pushOne(const PendingChange(
          id: 'b',
          status: SyncItemStatus.pending,
          retryCount: 0,
          payload: {}));

      verify(() => remote.addItem('Milch', '1L')).called(1);
      verify(() => dao.updateSyncStatus('b', 'synced', remoteId: 'remote-b'))
          .called(1);
    });

    test('pendingDelete calls remote.removeItem when remoteId set', () async {
      when(() => dao.getItemByLocalId('d')).thenAnswer((_) async => _row(
          localId: 'd', remoteId: 'rd', syncStatus: 'pendingDelete'));
      when(() => remote.removeItem(any())).thenAnswer((_) async {});

      await adapter.pushOne(const PendingChange(
          id: 'd',
          status: SyncItemStatus.pendingDelete,
          retryCount: 0,
          payload: {}));

      verify(() => remote.removeItem('rd')).called(1);
    });

    test('pendingDelete without remoteId is a no-op on remote', () async {
      when(() => dao.getItemByLocalId('d')).thenAnswer(
          (_) async => _row(localId: 'd', syncStatus: 'pendingDelete'));

      await adapter.pushOne(const PendingChange(
          id: 'd',
          status: SyncItemStatus.pendingDelete,
          retryCount: 0,
          payload: {}));

      verifyNever(() => remote.removeItem(any()));
    });

    test('missing local row is a silent no-op', () async {
      when(() => dao.getItemByLocalId('x')).thenAnswer((_) async => null);
      await adapter.pushOne(const PendingChange(
          id: 'x',
          status: SyncItemStatus.pending,
          retryCount: 0,
          payload: {}));
      verifyZeroInteractions(remote);
    });
  });

  test('pullSince rejects non-FullScope', () async {
    expect(
      () => adapter.pullSince(null, const MonthScope(2026, 4)),
      throwsArgumentError,
    );
  });

  group('applyRemote', () {
    test('no-op when no preceding pullSince', () async {
      await adapter.applyRemote([
        RemoteRow(
            id: 'r',
            updatedAt: DateTime(2026),
            deleted: false,
            data: const {
              'information': 'X',
              'quantity': null,
              'is_checked': false,
            }),
      ]);
      verifyNever(() => dao.replaceAllSynced(any(), any()));
    });

    test('after pullSince builds synced companions and calls replaceAllSynced',
        () async {
      adapter.debugSetHasPendingPull(true);

      when(() => dao.getSyncedItemsByGroup('g1')).thenAnswer((_) async => []);
      final captured = <List<LocalShoppingItemsCompanion>>[];
      when(() => dao.replaceAllSynced(any(), any()))
          .thenAnswer((inv) async {
        captured.add(inv.positionalArguments[1]
            as List<LocalShoppingItemsCompanion>);
      });

      await adapter.applyRemote([
        RemoteRow(
          id: 'remote-1',
          updatedAt: DateTime(2026, 4, 1),
          deleted: false,
          data: const {
            'id': 'remote-1',
            'information': 'Milch',
            'quantity': '1L',
            'is_checked': false,
          },
        ),
        RemoteRow(
          id: 'remote-2',
          updatedAt: DateTime(2026, 4, 1),
          deleted: false,
          data: const {
            'id': 'remote-2',
            'information': 'Brot',
            'quantity': null,
            'is_checked': true,
          },
        ),
      ]);

      verify(() => dao.replaceAllSynced('g1', any())).called(1);
      expect(captured.single.length, 2);
      expect(captured.single[0].information, const Value('Milch'));
      expect(captured.single[0].isChecked, const Value(false));
      expect(captured.single[1].information, const Value('Brot'));
      expect(captured.single[1].quantity, const Value<String?>(null));
      expect(captured.single[1].isChecked, const Value(true));
      expect(captured.single[0].syncStatus, const Value('synced'));
    });

    test('applyRemote bewahrt localId bei bekannter remoteId', () async {
      adapter.debugSetHasPendingPull(true);

      when(() => dao.getSyncedItemsByGroup('g1')).thenAnswer((_) async => [
            _row(localId: 'local-abc', remoteId: 'remote-1', syncStatus: 'synced'),
          ]);
      final captured = <List<LocalShoppingItemsCompanion>>[];
      when(() => dao.replaceAllSynced(any(), any())).thenAnswer((inv) async {
        captured.add(inv.positionalArguments[1] as List<LocalShoppingItemsCompanion>);
      });

      await adapter.applyRemote([
        RemoteRow(
          id: 'remote-1',
          updatedAt: DateTime(2026, 4, 1),
          deleted: false,
          data: const {'information': 'Milch', 'quantity': '1L', 'is_checked': false},
        ),
      ]);

      // localId muss die ursprüngliche bleiben, nicht zur remoteId werden
      expect(captured.single[0].localId, const Value('local-abc'));
      expect(captured.single[0].remoteId, const Value('remote-1'));
    });

    test('applyRemote nutzt remoteId als localId für neue Items (anderes Gerät)',
        () async {
      adapter.debugSetHasPendingPull(true);

      when(() => dao.getSyncedItemsByGroup('g1')).thenAnswer((_) async => []);
      final captured = <List<LocalShoppingItemsCompanion>>[];
      when(() => dao.replaceAllSynced(any(), any())).thenAnswer((inv) async {
        captured.add(inv.positionalArguments[1] as List<LocalShoppingItemsCompanion>);
      });

      await adapter.applyRemote([
        RemoteRow(
          id: 'remote-new',
          updatedAt: DateTime(2026, 4, 1),
          deleted: false,
          data: const {'information': 'Brot', 'quantity': null, 'is_checked': false},
        ),
      ]);

      // Neues Item vom Server: localId = remoteId
      expect(captured.single[0].localId, const Value('remote-new'));
      expect(captured.single[0].remoteId, const Value('remote-new'));
    });

    test('flag is cleared after applying', () async {
      adapter.debugSetHasPendingPull(true);
      when(() => dao.getSyncedItemsByGroup('g1')).thenAnswer((_) async => []);
      when(() => dao.replaceAllSynced(any(), any()))
          .thenAnswer((_) async {});
      await adapter.applyRemote(const []);
      verify(() => dao.getSyncedItemsByGroup('g1')).called(1);
      verify(() => dao.replaceAllSynced(any(), any())).called(1);

      await adapter.applyRemote(const []);
      verifyNoMoreInteractions(dao);
    });
  });
}
