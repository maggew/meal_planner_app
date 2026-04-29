import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/repositories/supabase_shopping_list_repository.dart';
import 'package:meal_planner/data/sync/local_sync_status.dart';
import 'package:meal_planner/data/sync/shopping_list_local_store.dart';
import 'package:meal_planner/data/sync/shopping_list_sync_adapter.dart';
import 'package:meal_planner/data/sync/sync_types.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:mocktail/mocktail.dart';

class _MockDao extends Mock implements ShoppingListLocalStore {}

class _MockRemote extends Mock implements SupabaseShoppingListRepository {}

ShoppingListRow _row({
  required String localId,
  String? remoteId,
  String information = 'Milch',
  String? quantity = '1L',
  bool isChecked = false,
  LocalSyncStatus syncStatus = LocalSyncStatus.pendingCreate,
}) =>
    ShoppingListRow(
      localId: localId,
      remoteId: remoteId,
      information: information,
      quantity: quantity,
      isChecked: isChecked,
      syncStatus: syncStatus,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(<ShoppingListSyncedRow>[]);
    registerFallbackValue(LocalSyncStatus.synced);
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
            _row(localId: 'a', syncStatus: LocalSyncStatus.pendingCreate),
            _row(localId: 'b', syncStatus: LocalSyncStatus.pendingUpdate, remoteId: 'rb'),
            _row(localId: 'c', syncStatus: LocalSyncStatus.failed, remoteId: 'rc'),
          ]);
      final res = await adapter.readPending();
      expect(res.map((c) => c.id).toList(), ['a', 'b', 'c']);
      expect(res.map((c) => c.status),
          everyElement(SyncItemStatus.pending));
    });

    test('maps pendingDelete to pendingDelete', () async {
      when(() => dao.getPendingItems('g1')).thenAnswer((_) async => [
            _row(localId: 'd', syncStatus: LocalSyncStatus.pendingDelete, remoteId: 'rd'),
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
          _row(localId: 'x', syncStatus: LocalSyncStatus.pendingDelete, remoteId: 'rx'));
      when(() => dao.hardDeleteItem('x')).thenAnswer((_) async {});
      await adapter.markSynced('x');
      verify(() => dao.hardDeleteItem('x')).called(1);
      verifyNever(() => dao.updateSyncStatus(any(), any()));
    });

    test('updates other rows to synced', () async {
      when(() => dao.getItemByLocalId('x')).thenAnswer(
          (_) async => _row(localId: 'x', syncStatus: LocalSyncStatus.pendingUpdate));
      when(() => dao.updateSyncStatus(any(), any())).thenAnswer((_) async {});
      await adapter.markSynced('x');
      verify(() => dao.updateSyncStatus('x', LocalSyncStatus.synced)).called(1);
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
    verify(() => dao.updateSyncStatus('x', LocalSyncStatus.failed)).called(1);
  });

  group('pushOne', () {
    test('pendingCreate calls remote.addItem and persists remoteId',
        () async {
      when(() => dao.getItemByLocalId('a')).thenAnswer(
          (_) async => _row(localId: 'a', syncStatus: LocalSyncStatus.pendingCreate));
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
      verify(() => dao.updateSyncStatus('a', LocalSyncStatus.synced,
              remoteId: 'remote-a'))
          .called(1);
    });

    test('pendingCreate with isChecked=true also toggles after insert',
        () async {
      when(() => dao.getItemByLocalId('a')).thenAnswer((_) async => _row(
          localId: 'a', syncStatus: LocalSyncStatus.pendingCreate, isChecked: true));
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
          syncStatus: LocalSyncStatus.pendingUpdate,
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
          _row(localId: 'b', syncStatus: LocalSyncStatus.pendingUpdate));
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
      verify(() => dao.updateSyncStatus('b', LocalSyncStatus.synced,
              remoteId: 'remote-b'))
          .called(1);
    });

    test('pendingDelete calls remote.removeItem when remoteId set', () async {
      when(() => dao.getItemByLocalId('d')).thenAnswer((_) async => _row(
          localId: 'd', remoteId: 'rd', syncStatus: LocalSyncStatus.pendingDelete));
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
          (_) async => _row(localId: 'd', syncStatus: LocalSyncStatus.pendingDelete));

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

    test('after pullSince builds synced rows and calls replaceAllSynced',
        () async {
      adapter.debugSetHasPendingPull(true);

      when(() => dao.getSyncedItemsByGroup('g1')).thenAnswer((_) async => []);
      final captured = <List<ShoppingListSyncedRow>>[];
      when(() => dao.replaceAllSynced(any(), any()))
          .thenAnswer((inv) async {
        captured.add(inv.positionalArguments[1] as List<ShoppingListSyncedRow>);
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
      expect(captured.single[0].information, 'Milch');
      expect(captured.single[0].isChecked, false);
      expect(captured.single[1].information, 'Brot');
      expect(captured.single[1].quantity, isNull);
      expect(captured.single[1].isChecked, true);
    });

    test('applyRemote bewahrt localId bei bekannter remoteId', () async {
      adapter.debugSetHasPendingPull(true);

      when(() => dao.getSyncedItemsByGroup('g1')).thenAnswer((_) async => [
            _row(localId: 'local-abc', remoteId: 'remote-1', syncStatus: LocalSyncStatus.synced),
          ]);
      final captured = <List<ShoppingListSyncedRow>>[];
      when(() => dao.replaceAllSynced(any(), any())).thenAnswer((inv) async {
        captured.add(inv.positionalArguments[1] as List<ShoppingListSyncedRow>);
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
      expect(captured.single[0].localId, 'local-abc');
      expect(captured.single[0].remoteId, 'remote-1');
    });

    test('applyRemote nutzt remoteId als localId für neue Items (anderes Gerät)',
        () async {
      adapter.debugSetHasPendingPull(true);

      when(() => dao.getSyncedItemsByGroup('g1')).thenAnswer((_) async => []);
      final captured = <List<ShoppingListSyncedRow>>[];
      when(() => dao.replaceAllSynced(any(), any())).thenAnswer((inv) async {
        captured.add(inv.positionalArguments[1] as List<ShoppingListSyncedRow>);
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
      expect(captured.single[0].localId, 'remote-new');
      expect(captured.single[0].remoteId, 'remote-new');
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
