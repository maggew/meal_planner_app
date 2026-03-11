import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/shopping_item_dao.dart';
import 'package:meal_planner/data/repositories/offline_first_shopping_list_repository.dart';
import 'package:meal_planner/data/repositories/supabase_shopping_list_repository.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:mocktail/mocktail.dart';

// ==================== Mocks ====================

class MockShoppingItemDao extends Mock implements ShoppingItemDao {}

class MockRemote extends Mock implements SupabaseShoppingListRepository {}

class _LocalShoppingItemsCompanionFake extends Fake
    implements LocalShoppingItemsCompanion {}

// ==================== Helpers ====================

const _kGroupId = 'gruppe-1';

LocalShoppingItem _fakeLocal({
  String localId = 'local-1',
  String? remoteId = 'remote-1',
  String groupId = _kGroupId,
  String information = 'Milch',
  String? quantity = '1L',
  bool isChecked = false,
  String syncStatus = 'synced',
}) =>
    LocalShoppingItem(
      localId: localId,
      remoteId: remoteId,
      groupId: groupId,
      information: information,
      quantity: quantity,
      isChecked: isChecked,
      syncStatus: syncStatus,
      updatedAt: DateTime(2026, 3, 10),
    );

ShoppingListItem _fakeRemoteItem({
  String id = 'remote-1',
  String groupId = _kGroupId,
  String information = 'Milch',
  String? quantity = '1L',
  bool isChecked = false,
}) =>
    ShoppingListItem(
      id: id,
      groupId: groupId,
      information: information,
      quantity: quantity,
      isChecked: isChecked,
    );

void main() {
  late MockShoppingItemDao mockDao;
  late MockRemote mockRemote;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(_LocalShoppingItemsCompanionFake());
  });

  setUp(() {
    mockDao = MockShoppingItemDao();
    mockRemote = MockRemote();
  });

  tearDown(() => container.dispose());

  OfflineFirstShoppingListRepository _buildRepo({
    required bool isOnline,
    String groupId = _kGroupId,
  }) {
    container = ProviderContainer(overrides: [
      isOnlineProvider.overrideWithValue(isOnline),
    ]);
    final testProvider = Provider<OfflineFirstShoppingListRepository>((ref) {
      return OfflineFirstShoppingListRepository(
        dao: mockDao,
        remote: mockRemote,
        groupId: groupId,
        ref: ref,
      );
    });
    return container.read(testProvider);
  }

  void _stubDaoVoids() {
    when(() => mockDao.upsertItem(any())).thenAnswer((_) async {});
    when(() => mockDao.updateSyncStatus(any(), any(),
        remoteId: any(named: 'remoteId'))).thenAnswer((_) async {});
    when(() => mockDao.markAsDeleted(any())).thenAnswer((_) async {});
    when(() => mockDao.hardDeleteItem(any())).thenAnswer((_) async {});
  }

  // DAO-Stream für eine einmalige Abfrage (.first) konfigurieren
  void _stubDaoList(List<LocalShoppingItem> items) {
    when(() => mockDao.watchItemsByGroup(any()))
        .thenAnswer((_) => Stream.value(items));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 1 — watchItems: Stream-Vertrag
  // ═══════════════════════════════════════════════════════════════════════════

  group('watchItems', () {
    test('1 — leere Liste wenn DAO keine Items liefert', () async {
      final ctrl = StreamController<List<LocalShoppingItem>>.broadcast();
      when(() => mockDao.watchItemsByGroup(_kGroupId))
          .thenAnswer((_) => ctrl.stream);
      final repo = _buildRepo(isOnline: false);

      final future = expectLater(repo.watchItems(), emits(isEmpty));
      ctrl.add([]);
      await future;
      await ctrl.close();
    });

    test('2 — Gruppen-Isolation: DAO wird mit der eigenen groupId abgefragt',
        () async {
      final ctrl = StreamController<List<LocalShoppingItem>>.broadcast();
      when(() => mockDao.watchItemsByGroup('gruppe-A'))
          .thenAnswer((_) => ctrl.stream);
      final repo = _buildRepo(isOnline: false, groupId: 'gruppe-A');

      repo.watchItems().listen((_) {});

      verify(() => mockDao.watchItemsByGroup('gruppe-A')).called(1);
      verifyNever(() => mockDao.watchItemsByGroup('gruppe-B'));
      await ctrl.close();
    });

    test('3 — id in Entity ist remoteId wenn vorhanden, sonst localId',
        () async {
      final ctrl = StreamController<List<LocalShoppingItem>>.broadcast();
      when(() => mockDao.watchItemsByGroup(any()))
          .thenAnswer((_) => ctrl.stream);
      final repo = _buildRepo(isOnline: false);

      final future = expectLater(
        repo.watchItems(),
        emitsInOrder([
          predicate<List<ShoppingListItem>>(
            (items) =>
                items[0].id == 'remote-abc' && // remoteId vorhanden
                items[1].id == 'local-xyz', // kein remoteId → localId
          ),
        ]),
      );
      ctrl.add([
        _fakeLocal(localId: 'local-abc', remoteId: 'remote-abc'),
        _fakeLocal(localId: 'local-xyz', remoteId: null),
      ]);
      await future;
      await ctrl.close();
    });

    test('4 — Entity-Felder werden korrekt gemappt', () async {
      final ctrl = StreamController<List<LocalShoppingItem>>.broadcast();
      when(() => mockDao.watchItemsByGroup(any()))
          .thenAnswer((_) => ctrl.stream);
      final repo = _buildRepo(isOnline: false);

      final future = expectLater(
        repo.watchItems(),
        emits(predicate<List<ShoppingListItem>>(
          (items) {
            final item = items.first;
            return item.information == 'Butter' &&
                item.quantity == '250g' &&
                item.isChecked == true &&
                item.groupId == _kGroupId;
          },
        )),
      );
      ctrl.add([
        _fakeLocal(information: 'Butter', quantity: '250g', isChecked: true),
      ]);
      await future;
      await ctrl.close();
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 2 — getItems: Snapshot-Vertrag
  // ═══════════════════════════════════════════════════════════════════════════

  group('getItems', () {
    test('5 — gibt aktuelle Items als Liste zurück', () async {
      _stubDaoList([_fakeLocal(information: 'Eier')]);
      final repo = _buildRepo(isOnline: false);

      final items = await repo.getItems();

      expect(items, hasLength(1));
      expect(items.first.information, 'Eier');
    });

    test('6 — Gruppen-Isolation: DAO wird mit der eigenen groupId abgefragt',
        () async {
      when(() => mockDao.watchItemsByGroup('gruppe-X'))
          .thenAnswer((_) => Stream.value([]));
      final repo = _buildRepo(isOnline: false, groupId: 'gruppe-X');

      await repo.getItems();

      verify(() => mockDao.watchItemsByGroup('gruppe-X')).called(1);
      verifyNever(() => mockDao.watchItemsByGroup('gruppe-Y'));
    });

    test('7 — id ist remoteId wenn vorhanden, sonst localId', () async {
      _stubDaoList([
        _fakeLocal(localId: 'l-1', remoteId: 'r-1'),
        _fakeLocal(localId: 'l-2', remoteId: null),
      ]);
      final repo = _buildRepo(isOnline: false);

      final items = await repo.getItems();

      expect(items[0].id, 'r-1');
      expect(items[1].id, 'l-2');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 3 — addItem: Online
  // ═══════════════════════════════════════════════════════════════════════════

  group('addItem – online', () {
    test('8 — Online: Item wird lokal gespeichert (upsertItem aufgerufen)',
        () async {
      _stubDaoVoids();
      when(() => mockRemote.addItem(any(), any()))
          .thenAnswer((_) async => _fakeRemoteItem(id: 'remote-new'));
      final repo = _buildRepo(isOnline: true);

      await repo.addItem('Brot', null);

      verify(() => mockDao.upsertItem(any())).called(1);
    });

    test('9 — Online: Remote wird aufgerufen', () async {
      _stubDaoVoids();
      when(() => mockRemote.addItem('Brot', null))
          .thenAnswer((_) async => _fakeRemoteItem(id: 'remote-new'));
      final repo = _buildRepo(isOnline: true);

      await repo.addItem('Brot', null);

      verify(() => mockRemote.addItem('Brot', null)).called(1);
    });

    test(
        '10 — Online + Erfolg: updateSyncStatus mit synced und remoteId aufgerufen',
        () async {
      _stubDaoVoids();
      when(() => mockRemote.addItem(any(), any()))
          .thenAnswer((_) async => _fakeRemoteItem(id: 'remote-new'));
      final repo = _buildRepo(isOnline: true);

      await repo.addItem('Brot', null);

      verify(() => mockDao.updateSyncStatus(
            any(),
            'synced',
            remoteId: 'remote-new',
          )).called(1);
    });

    test('11 — Online + Erfolg: Rückgabewert ist das Remote-Item', () async {
      _stubDaoVoids();
      final remoteItem = _fakeRemoteItem(id: 'remote-xyz', information: 'Brot');
      when(() => mockRemote.addItem(any(), any()))
          .thenAnswer((_) async => remoteItem);
      final repo = _buildRepo(isOnline: true);

      final result = await repo.addItem('Brot', null);

      expect(result.id, 'remote-xyz');
    });

    test(
        '12 — Online + Remote-Fehler: Rückgabewert ist lokales Item, kein Absturz',
        () async {
      _stubDaoVoids();
      when(() => mockRemote.addItem(any(), any()))
          .thenThrow(Exception('Netzwerkfehler'));
      final repo = _buildRepo(isOnline: true);

      final result = await repo.addItem('Brot', '2 Stück');

      expect(result.information, 'Brot');
      expect(result.quantity, '2 Stück');
      expect(result.isChecked, false);
      // syncStatus bleibt pendingCreate — kein updateSyncStatus('synced') aufgerufen
      verifyNever(() => mockDao.updateSyncStatus(
            any(),
            'synced',
            remoteId: any(named: 'remoteId'),
          ));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 4 — addItem: Offline
  // ═══════════════════════════════════════════════════════════════════════════

  group('addItem – offline', () {
    test('13 — Offline: Item wird lokal mit pendingCreate gespeichert',
        () async {
      _stubDaoVoids();
      final repo = _buildRepo(isOnline: false);

      await repo.addItem('Käse', null);

      final captured = verify(() => mockDao.upsertItem(captureAny())).captured;
      final companion = captured.first as LocalShoppingItemsCompanion;
      expect(companion.syncStatus.value, 'pendingCreate');
    });

    test('14 — Offline: Remote wird nicht aufgerufen', () async {
      _stubDaoVoids();
      final repo = _buildRepo(isOnline: false);

      await repo.addItem('Käse', null);

      verifyNever(() => mockRemote.addItem(any(), any()));
    });

    test('15 — Offline: Rückgabewert ist lokales Item mit localId', () async {
      _stubDaoVoids();
      final repo = _buildRepo(isOnline: false);

      final result = await repo.addItem('Käse', '200g');

      expect(result.information, 'Käse');
      expect(result.quantity, '200g');
      expect(result.id, isNotEmpty); // localId, kein leerer String
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 5 — addItem: Daten
  // ═══════════════════════════════════════════════════════════════════════════

  group('addItem – Daten', () {
    test('16 — Jeder addItem-Aufruf erzeugt eine einzigartige localId',
        () async {
      _stubDaoVoids();
      final repo = _buildRepo(isOnline: false);

      await repo.addItem('Milch', null);
      await repo.addItem('Brot', null);

      final captured = verify(() => mockDao.upsertItem(captureAny())).captured;
      final id1 = (captured[0] as LocalShoppingItemsCompanion).localId.value;
      final id2 = (captured[1] as LocalShoppingItemsCompanion).localId.value;
      expect(id1, isNot(equals(id2)));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 6 — updateItem
  // ═══════════════════════════════════════════════════════════════════════════

  group('updateItem', () {
    test('17 — Online: lokales Item wird aktualisiert (upsertItem aufgerufen)',
        () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(remoteId: 'remote-1')]);
      when(() => mockRemote.updateItem(any(), any(), any()))
          .thenAnswer((_) async {});
      final repo = _buildRepo(isOnline: true);

      await repo.updateItem('remote-1', 'Milch 2%', '1L');

      verify(() => mockDao.upsertItem(any())).called(1);
    });

    test('18 — Online + Erfolg: Remote aufgerufen und syncStatus=synced',
        () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(remoteId: 'remote-1')]);
      when(() => mockRemote.updateItem(any(), any(), any()))
          .thenAnswer((_) async {});
      final repo = _buildRepo(isOnline: true);

      await repo.updateItem('remote-1', 'Milch 2%', '1L');

      verify(() => mockRemote.updateItem('remote-1', 'Milch 2%', '1L'))
          .called(1);
      verify(() => mockDao.updateSyncStatus('local-1', 'synced')).called(1);
    });

    test(

        '19 — Online + Remote-Fehler: lokales Update bleibt erhalten, kein Absturz',
        () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(remoteId: 'remote-1')]);
      when(() => mockRemote.updateItem(any(), any(), any()))
          .thenThrow(Exception('Netzwerkfehler'));
      final repo = _buildRepo(isOnline: true);

      await expectLater(
        repo.updateItem('remote-1', 'Milch 2%', '1L'),
        completes,
      );

      verify(() => mockDao.upsertItem(any())).called(1);
      verifyNever(() => mockDao.updateSyncStatus(any(), 'synced'));
    });

    test('20 — Offline: nur lokales Update, Remote wird nicht aufgerufen',
        () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(remoteId: 'remote-1')]);
      final repo = _buildRepo(isOnline: false);

      await repo.updateItem('remote-1', 'Milch 2%', '1L');

      verify(() => mockDao.upsertItem(any())).called(1);
      verifyNever(() => mockRemote.updateItem(any(), any(), any()));
    });

    test(
        '21 — Item mit pendingCreate bleibt pendingCreate nach Update (kein pendingUpdate)',
        () async {
      _stubDaoVoids();
      _stubDaoList([
        _fakeLocal(
          localId: 'local-unsynced',
          remoteId: null,
          syncStatus: 'pendingCreate',
        )
      ]);
      final repo = _buildRepo(isOnline: false);

      await repo.updateItem('local-unsynced', 'Neue Info', null);

      final captured = verify(() => mockDao.upsertItem(captureAny())).captured;
      final companion = captured.first as LocalShoppingItemsCompanion;
      expect(companion.syncStatus.value, 'pendingCreate');
    });

    test(
        '35 — Online + Remote-Fehler: syncStatus=pendingUpdate im lokalen Companion',
        () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(remoteId: 'remote-1', syncStatus: 'synced')]);
      when(() => mockRemote.updateItem(any(), any(), any()))
          .thenThrow(Exception('Netzwerkfehler'));
      final repo = _buildRepo(isOnline: true);

      await repo.updateItem('remote-1', 'Milch 2%', '1L');

      final captured = verify(() => mockDao.upsertItem(captureAny())).captured;
      final companion = captured.first as LocalShoppingItemsCompanion;
      expect(companion.syncStatus.value, 'pendingUpdate');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 7 — toggleItem
  // ═══════════════════════════════════════════════════════════════════════════

  group('toggleItem', () {
    test('22 — Online: lokaler Toggle wird durchgeführt', () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(remoteId: 'remote-1', isChecked: false)]);
      when(() => mockRemote.toggleItem(any(), any())).thenAnswer((_) async {});
      final repo = _buildRepo(isOnline: true);

      await repo.toggleItem('remote-1', true);

      final captured = verify(() => mockDao.upsertItem(captureAny())).captured;
      final companion = captured.first as LocalShoppingItemsCompanion;
      expect(companion.isChecked.value, true);
    });

    test('23 — Online + Erfolg: Remote aufgerufen und syncStatus=synced',
        () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(remoteId: 'remote-1')]);
      when(() => mockRemote.toggleItem(any(), any())).thenAnswer((_) async {});
      final repo = _buildRepo(isOnline: true);

      await repo.toggleItem('remote-1', true);

      verify(() => mockRemote.toggleItem('remote-1', true)).called(1);
      verify(() => mockDao.updateSyncStatus('local-1', 'synced')).called(1);
    });

    test('24 — Online + Remote-Fehler: lokaler Toggle bleibt, kein Absturz',
        () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(remoteId: 'remote-1')]);
      when(() => mockRemote.toggleItem(any(), any()))
          .thenThrow(Exception('Netzwerkfehler'));
      final repo = _buildRepo(isOnline: true);

      await expectLater(repo.toggleItem('remote-1', true), completes);

      verify(() => mockDao.upsertItem(any())).called(1);
      verifyNever(() => mockDao.updateSyncStatus(any(), 'synced'));
    });

    test('25 — Offline: nur lokaler Toggle, Remote wird nicht aufgerufen',
        () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(remoteId: 'remote-1')]);
      final repo = _buildRepo(isOnline: false);

      await repo.toggleItem('remote-1', true);

      verify(() => mockDao.upsertItem(any())).called(1);
      verifyNever(() => mockRemote.toggleItem(any(), any()));
    });

    test(
        '36 — Item mit pendingCreate bleibt pendingCreate nach Toggle (kein pendingUpdate)',
        () async {
      _stubDaoVoids();
      _stubDaoList([
        _fakeLocal(
          localId: 'local-unsynced',
          remoteId: null,
          syncStatus: 'pendingCreate',
          isChecked: false,
        )
      ]);
      final repo = _buildRepo(isOnline: false);

      await repo.toggleItem('local-unsynced', true);

      final captured = verify(() => mockDao.upsertItem(captureAny())).captured;
      final companion = captured.first as LocalShoppingItemsCompanion;
      expect(companion.syncStatus.value, 'pendingCreate');
    });

    test(
        '37 — Online + Remote-Fehler: syncStatus=pendingUpdate im lokalen Companion',
        () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(remoteId: 'remote-1', syncStatus: 'synced')]);
      when(() => mockRemote.toggleItem(any(), any()))
          .thenThrow(Exception('Netzwerkfehler'));
      final repo = _buildRepo(isOnline: true);

      await repo.toggleItem('remote-1', true);

      final captured = verify(() => mockDao.upsertItem(captureAny())).captured;
      final companion = captured.first as LocalShoppingItemsCompanion;
      expect(companion.syncStatus.value, 'pendingUpdate');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 8 — removeItem
  // ═══════════════════════════════════════════════════════════════════════════

  group('removeItem', () {
    test(
        '26 — Online + Erfolg: Reihenfolge markAsDeleted → Remote → hardDelete',
        () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(localId: 'local-1', remoteId: 'remote-1')]);
      when(() => mockRemote.removeItem(any())).thenAnswer((_) async {});
      final callOrder = <String>[];
      when(() => mockDao.markAsDeleted('local-1'))
          .thenAnswer((_) async => callOrder.add('markAsDeleted'));
      when(() => mockRemote.removeItem(any()))
          .thenAnswer((_) async => callOrder.add('remote'));
      when(() => mockDao.hardDeleteItem(any()))
          .thenAnswer((_) async => callOrder.add('hardDelete'));
      final repo = _buildRepo(isOnline: true);

      await repo.removeItem('remote-1');

      expect(callOrder, ['markAsDeleted', 'remote', 'hardDelete']);
    });

    test('27 — Offline: nur markAsDeleted, kein Remote, kein hardDelete',
        () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(localId: 'local-1', remoteId: 'remote-1')]);
      final repo = _buildRepo(isOnline: false);

      await repo.removeItem('remote-1');

      verify(() => mockDao.markAsDeleted('local-1')).called(1);
      verifyNever(() => mockRemote.removeItem(any()));
      verifyNever(() => mockDao.hardDeleteItem(any()));
    });

    test('28 — Online + Remote-Fehler: bleibt pendingDelete, kein hardDelete',
        () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(localId: 'local-1', remoteId: 'remote-1')]);
      when(() => mockRemote.removeItem(any()))
          .thenThrow(Exception('Netzwerkfehler'));
      final repo = _buildRepo(isOnline: true);

      await expectLater(repo.removeItem('remote-1'), completes);

      verify(() => mockDao.markAsDeleted('local-1')).called(1);
      verifyNever(() => mockDao.hardDeleteItem(any()));
    });

    test('29 — Item-Lookup funktioniert nach remoteId', () async {
      _stubDaoVoids();
      // localId ≠ itemId, remoteId == itemId
      _stubDaoList([_fakeLocal(localId: 'local-xyz', remoteId: 'remote-abc')]);
      when(() => mockRemote.removeItem(any())).thenAnswer((_) async {});
      final repo = _buildRepo(isOnline: true);

      await repo.removeItem('remote-abc');

      // markAsDeleted muss mit der localId aufgerufen werden
      verify(() => mockDao.markAsDeleted('local-xyz')).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 9 — removeCheckedItems
  // ═══════════════════════════════════════════════════════════════════════════

  group('removeCheckedItems', () {
    test('30 — Nur abgehakte Items werden gelöscht, nicht-abgehakte bleiben',
        () async {
      _stubDaoVoids();
      _stubDaoList([
        _fakeLocal(localId: 'checked-1', isChecked: true),
        _fakeLocal(localId: 'unchecked-1', isChecked: false),
      ]);
      when(() => mockRemote.removeCheckedItems()).thenAnswer((_) async {});
      final repo = _buildRepo(isOnline: true);

      await repo.removeCheckedItems();

      verify(() => mockDao.markAsDeleted('checked-1')).called(1);
      verifyNever(() => mockDao.markAsDeleted('unchecked-1'));
    });

    test(
        '31 — Online + Erfolg: markAsDeleted → Remote → hardDelete für alle abgehakten',
        () async {
      _stubDaoVoids();
      _stubDaoList([
        _fakeLocal(localId: 'checked-1', isChecked: true),
        _fakeLocal(localId: 'checked-2', isChecked: true),
      ]);
      when(() => mockRemote.removeCheckedItems()).thenAnswer((_) async {});
      final repo = _buildRepo(isOnline: true);

      await repo.removeCheckedItems();

      verify(() => mockDao.markAsDeleted('checked-1')).called(1);
      verify(() => mockDao.markAsDeleted('checked-2')).called(1);
      verify(() => mockRemote.removeCheckedItems()).called(1);
      verify(() => mockDao.hardDeleteItem('checked-1')).called(1);
      verify(() => mockDao.hardDeleteItem('checked-2')).called(1);
    });

    test(
        '32 — Offline: alle abgehakten markAsDeleted, kein Remote, kein hardDelete',
        () async {
      _stubDaoVoids();
      _stubDaoList([
        _fakeLocal(localId: 'checked-1', isChecked: true),
      ]);
      final repo = _buildRepo(isOnline: false);

      await repo.removeCheckedItems();

      verify(() => mockDao.markAsDeleted('checked-1')).called(1);
      verifyNever(() => mockRemote.removeCheckedItems());
      verifyNever(() => mockDao.hardDeleteItem(any()));
    });

    test(
        '33 — Online + Remote-Fehler: abgehakte bleiben pendingDelete, kein hardDelete',
        () async {
      _stubDaoVoids();
      _stubDaoList([
        _fakeLocal(localId: 'checked-1', isChecked: true),
      ]);
      when(() => mockRemote.removeCheckedItems())
          .thenThrow(Exception('Netzwerkfehler'));
      final repo = _buildRepo(isOnline: true);

      await expectLater(repo.removeCheckedItems(), completes);

      verify(() => mockDao.markAsDeleted('checked-1')).called(1);
      verifyNever(() => mockDao.hardDeleteItem(any()));
    });

    test('34 — Keine abgehakten Items: kein Remote-Aufruf, keine Deletions',
        () async {
      _stubDaoVoids();
      _stubDaoList([
        _fakeLocal(localId: 'unchecked-1', isChecked: false),
      ]);
      final repo = _buildRepo(isOnline: true);

      await repo.removeCheckedItems();

      verifyNever(() => mockRemote.removeCheckedItems());
      verifyNever(() => mockDao.markAsDeleted(any()));
      verifyNever(() => mockDao.hardDeleteItem(any()));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 10 — Lookup per localId
  // ═══════════════════════════════════════════════════════════════════════════

  group('Lookup per localId', () {
    test('38 — updateItem: Lookup funktioniert nach localId', () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(localId: 'local-abc', remoteId: null)]);
      final repo = _buildRepo(isOnline: false);

      await repo.updateItem('local-abc', 'Neue Info', '500g');

      final captured = verify(() => mockDao.upsertItem(captureAny())).captured;
      final companion = captured.first as LocalShoppingItemsCompanion;
      expect(companion.localId.value, 'local-abc');
      expect(companion.information.value, 'Neue Info');
    });

    test('39 — toggleItem: Lookup funktioniert nach localId', () async {
      _stubDaoVoids();
      _stubDaoList([
        _fakeLocal(localId: 'local-abc', remoteId: null, isChecked: false),
      ]);
      final repo = _buildRepo(isOnline: false);

      await repo.toggleItem('local-abc', true);

      final captured = verify(() => mockDao.upsertItem(captureAny())).captured;
      final companion = captured.first as LocalShoppingItemsCompanion;
      expect(companion.localId.value, 'local-abc');
      expect(companion.isChecked.value, true);
    });

    test('40 — removeItem: Lookup funktioniert nach localId', () async {
      _stubDaoVoids();
      _stubDaoList([_fakeLocal(localId: 'local-abc', remoteId: null)]);
      final repo = _buildRepo(isOnline: false);

      await repo.removeItem('local-abc');

      verify(() => mockDao.markAsDeleted('local-abc')).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 11 — Nicht-existentes Item
  // ═══════════════════════════════════════════════════════════════════════════

  group('Nicht-existentes Item', () {
    test('41 — updateItem wirft Exception für nicht-existente ID', () async {
      _stubDaoList([]);
      final repo = _buildRepo(isOnline: false);

      await expectLater(
        repo.updateItem('ghost-id', 'Info', null),
        throwsA(isA<Exception>()),
      );
    });

    test('42 — toggleItem wirft Exception für nicht-existente ID', () async {
      _stubDaoList([]);
      final repo = _buildRepo(isOnline: false);

      await expectLater(
        repo.toggleItem('ghost-id', true),
        throwsA(isA<Exception>()),
      );
    });

    test('43 — removeItem wirft Exception für nicht-existente ID', () async {
      _stubDaoList([]);
      final repo = _buildRepo(isOnline: false);

      await expectLater(
        repo.removeItem('ghost-id'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
