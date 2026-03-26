import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/shopping_item_dao.dart';
import 'package:meal_planner/data/repositories/offline_first_shopping_list_repository.dart';
import 'package:meal_planner/data/repositories/supabase_shopping_list_repository.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:mocktail/mocktail.dart';

// --- Mocks ---

class MockShoppingItemDao extends Mock implements ShoppingItemDao {}

class MockSupabaseShoppingListRepository extends Mock
    implements SupabaseShoppingListRepository {}

class FakeLocalShoppingItemsCompanion extends Fake
    implements LocalShoppingItemsCompanion {}

// --- Fixture-Helper ---

LocalShoppingItem _item({
  String localId = 'local-1',
  String? remoteId,
  String information = 'Tomaten',
  String? quantity,
  bool isChecked = false,
  required String syncStatus,
}) {
  return LocalShoppingItem(
    localId: localId,
    remoteId: remoteId,
    groupId: 'g1',
    information: information,
    quantity: quantity,
    isChecked: isChecked,
    syncStatus: syncStatus,
    updatedAt: DateTime(2026),
  );
}

ShoppingListItem _remoteItem({String id = 'remote-1', String information = 'Tomaten'}) {
  return ShoppingListItem(
    id: id,
    groupId: 'g1',
    information: information,
    quantity: null,
    isChecked: false,
  );
}

// =============================================================================

void main() {
  late MockShoppingItemDao dao;
  late MockSupabaseShoppingListRepository remote;
  late OfflineFirstShoppingListRepository repo;

  setUpAll(() {
    registerFallbackValue(FakeLocalShoppingItemsCompanion());
  });

  setUp(() {
    dao = MockShoppingItemDao();
    remote = MockSupabaseShoppingListRepository();
    repo = OfflineFirstShoppingListRepository(dao: dao, remote: remote, groupId: 'g1');
  });

  // ---------------------------------------------------------------------------

  group('syncPendingItems – pendingCreate', () {
    test('synct neues Item zu Remote und speichert remoteId lokal', () async {
      when(() => dao.getPendingItems('g1')).thenAnswer(
        (_) async => [_item(syncStatus: 'pendingCreate')],
      );
      when(() => remote.addItem(any(), any())).thenAnswer(
        (_) async => _remoteItem(id: 'remote-1'),
      );
      when(() => dao.updateSyncStatus(any(), any(), remoteId: any(named: 'remoteId')))
          .thenAnswer((_) async {});

      await repo.syncPendingItems();

      verify(() => remote.addItem('Tomaten', null)).called(1);
      verify(() =>
              dao.updateSyncStatus('local-1', 'synced', remoteId: 'remote-1'))
          .called(1);
    });

    test('überspringt fehlerhafte Items und synct die restlichen', () async {
      when(() => dao.getPendingItems('g1')).thenAnswer(
        (_) async => [
          _item(localId: 'l1', syncStatus: 'pendingCreate'),
          _item(localId: 'l2', information: 'Mehl', syncStatus: 'pendingCreate'),
        ],
      );
      // l1 schlägt fehl, l2 gelingt
      var callCount = 0;
      when(() => remote.addItem(any(), any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) throw Exception('Netzwerkfehler');
        return _remoteItem(id: 'remote-2', information: 'Mehl');
      });
      when(() => dao.updateSyncStatus(any(), any(), remoteId: any(named: 'remoteId')))
          .thenAnswer((_) async {});

      await repo.syncPendingItems();

      verify(() => remote.addItem(any(), any())).called(2);
      // Nur l2 wird als synced markiert
      verify(() =>
              dao.updateSyncStatus('l2', 'synced', remoteId: 'remote-2'))
          .called(1);
      verifyNever(
          () => dao.updateSyncStatus('l1', any(), remoteId: any(named: 'remoteId')));
    });
  });

  // ---------------------------------------------------------------------------

  group('syncPendingItems – pendingUpdate', () {
    test(
        'pendingUpdate synct Name, Menge UND isChecked zu Remote',
        () async {
      // Szenario: Benutzer hat offline den Namen von "Tomaten" auf "Rispentomaten"
      // und die Menge von null auf "500g" geändert
      when(() => dao.getPendingItems('g1')).thenAnswer(
        (_) async => [
          _item(
            syncStatus: 'pendingUpdate',
            remoteId: 'remote-1',
            information: 'Rispentomaten',
            quantity: '500g',
            isChecked: false,
          ),
        ],
      );
      when(() => remote.updateItem(any(), any(), any())).thenAnswer((_) async {});
      when(() => remote.toggleItem(any(), any())).thenAnswer((_) async {});
      when(() => dao.updateSyncStatus(any(), any())).thenAnswer((_) async {});

      await repo.syncPendingItems();

      // updateItem synct Name + Menge
      verify(() => remote.updateItem('remote-1', 'Rispentomaten', '500g')).called(1);
      // toggleItem synct isChecked
      verify(() => remote.toggleItem('remote-1', false)).called(1);
      verify(() => dao.updateSyncStatus('local-1', 'synced')).called(1);
    });

    test('pendingUpdate ohne remoteId fällt auf addItem zurück (statt still zu überspringen)',
        () async {
      // Szenario: Item wurde offline erstellt und bearbeitet bevor es synced wurde.
      // Dank des Repository-Fixes bleibt der Status pendingCreate – aber als
      // Belt-and-suspenders behandelt der SyncService pendingUpdate+noRemoteId
      // als pendingCreate und erstellt das Item auf dem Server.
      when(() => dao.getPendingItems('g1')).thenAnswer(
        (_) async => [
          _item(
            syncStatus: 'pendingUpdate',
            remoteId: null,
            information: 'Offline-Item',
          ),
        ],
      );
      when(() => remote.addItem(any(), any())).thenAnswer(
        (_) async => _remoteItem(id: 'remote-fallback', information: 'Offline-Item'),
      );
      when(() => dao.updateSyncStatus(any(), any(), remoteId: any(named: 'remoteId')))
          .thenAnswer((_) async {});

      await repo.syncPendingItems();

      verify(() => remote.addItem('Offline-Item', null)).called(1);
      verify(() => dao.updateSyncStatus('local-1', 'synced', remoteId: 'remote-fallback'))
          .called(1);
    });

    test('pendingUpdate mit remoteId: markiert lokal als synced', () async {
      when(() => dao.getPendingItems('g1')).thenAnswer(
        (_) async => [
          _item(
            syncStatus: 'pendingUpdate',
            remoteId: 'remote-1',
            isChecked: true,
          ),
        ],
      );
      when(() => remote.updateItem(any(), any(), any())).thenAnswer((_) async {});
      when(() => remote.toggleItem(any(), any())).thenAnswer((_) async {});
      when(() => dao.updateSyncStatus(any(), any())).thenAnswer((_) async {});

      await repo.syncPendingItems();

      verify(() => remote.updateItem('remote-1', 'Tomaten', null)).called(1);
      verify(() => remote.toggleItem('remote-1', true)).called(1);
      verify(() => dao.updateSyncStatus('local-1', 'synced')).called(1);
    });
  });

  // ---------------------------------------------------------------------------

  group('syncPendingItems – pendingDelete', () {
    test('löscht Item remote und hard-deleted lokal', () async {
      when(() => dao.getPendingItems('g1')).thenAnswer(
        (_) async => [
          _item(syncStatus: 'pendingDelete', remoteId: 'remote-1'),
        ],
      );
      when(() => remote.removeItem(any())).thenAnswer((_) async {});
      when(() => dao.hardDeleteItem(any())).thenAnswer((_) async {});

      await repo.syncPendingItems();

      verify(() => remote.removeItem('remote-1')).called(1);
      verify(() => dao.hardDeleteItem('local-1')).called(1);
    });

    test('pendingDelete ohne remoteId: hard-deleted nur lokal (kein Remote-Aufruf)', () async {
      when(() => dao.getPendingItems('g1')).thenAnswer(
        (_) async => [
          _item(syncStatus: 'pendingDelete', remoteId: null),
        ],
      );
      when(() => dao.hardDeleteItem(any())).thenAnswer((_) async {});

      await repo.syncPendingItems();

      verifyNever(() => remote.removeItem(any()));
      verify(() => dao.hardDeleteItem('local-1')).called(1);
    });
  });
}
