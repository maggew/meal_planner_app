import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/repositories/supabase_shopping_list_repository.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Fake infrastructure ──────────────────────────────────────────────────────
//
// Supabase's PostgrestBuilder<T> implements Future<T>, making mocktail
// impractical. We use hand-written fakes following the same pattern as the
// other Supabase repository tests.

typedef _Row = Map<String, dynamic>;

// Terminal fake for .single() — resolves as PostgrestMap.
class _FakeMapChain extends Fake
    implements PostgrestTransformBuilder<PostgrestMap> {
  final PostgrestMap _value;
  final bool _throws;

  _FakeMapChain(PostgrestMap value, {bool throws = false})
      : _value = value,
        _throws = throws;

  @override
  Future<R> then<R>(FutureOr<R> Function(PostgrestMap) onValue,
          {Function? onError}) =>
      _future().then(onValue, onError: onError);

  @override
  Future<PostgrestMap> catchError(Function f, {bool Function(Object)? test}) =>
      _future().catchError(f, test: test);

  @override
  Future<PostgrestMap> whenComplete(FutureOr<void> Function() action) =>
      _future().whenComplete(action);

  @override
  Future<PostgrestMap> timeout(Duration d,
          {FutureOr<PostgrestMap> Function()? onTimeout}) =>
      _future().timeout(d, onTimeout: onTimeout);

  @override
  Stream<PostgrestMap> asStream() => _future().asStream();

  Future<PostgrestMap> _future() => _throws
      ? Future<PostgrestMap>.error(Exception('supabase error'))
      : Future.value(_value);
}

// Fake for list-returning chains — resolves as PostgrestList.
// Supports .order() and .single() for chained operations.
class _FakeListChain extends Fake
    implements PostgrestTransformBuilder<PostgrestList> {
  final PostgrestList _value;
  final bool _throws;

  _FakeListChain(List<PostgrestMap> value, {bool throws = false})
      : _value = value,
        _throws = throws;

  @override
  PostgrestTransformBuilder<PostgrestList> order(String column,
          {bool ascending = true,
          bool nullsFirst = false,
          String? referencedTable}) =>
      this;

  @override
  PostgrestTransformBuilder<PostgrestMap> single() =>
      _FakeMapChain(_value.isNotEmpty ? _value.first : {}, throws: _throws);

  @override
  Future<R> then<R>(FutureOr<R> Function(PostgrestList) onValue,
          {Function? onError}) =>
      _future().then(onValue, onError: onError);

  @override
  Future<PostgrestList> catchError(Function f, {bool Function(Object)? test}) =>
      _future().catchError(f, test: test);

  @override
  Future<PostgrestList> whenComplete(FutureOr<void> Function() action) =>
      _future().whenComplete(action);

  @override
  Future<PostgrestList> timeout(Duration d,
          {FutureOr<PostgrestList> Function()? onTimeout}) =>
      _future().timeout(d, onTimeout: onTimeout);

  @override
  Stream<PostgrestList> asStream() => _future().asStream();

  Future<PostgrestList> _future() => _throws
      ? Future<PostgrestList>.error(Exception('supabase error'))
      : Future.value(_value);
}

// General filter-chain fake — supports eq(), order(), select().
class _FakeChain<T> extends Fake implements PostgrestFilterBuilder<T> {
  final dynamic _response;
  final bool _throws;

  _FakeChain(this._response, {bool throws = false}) : _throws = throws;

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<T> order(String column,
          {bool ascending = true,
          bool nullsFirst = false,
          String? referencedTable}) =>
      this;

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) {
    final list = _response is List
        ? (_response as List).cast<PostgrestMap>()
        : <PostgrestMap>[];
    return _FakeListChain(list, throws: _throws);
  }

  @override
  Future<R> then<R>(FutureOr<R> Function(T) onValue, {Function? onError}) =>
      _future().then(onValue, onError: onError);

  @override
  Future<T> catchError(Function f, {bool Function(Object)? test}) =>
      _future().catchError(f, test: test);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _future().whenComplete(action);

  @override
  Future<T> timeout(Duration d, {FutureOr<T> Function()? onTimeout}) =>
      _future().timeout(d, onTimeout: onTimeout);

  @override
  Stream<T> asStream() => _future().asStream();

  Future<T> _future() => _throws
      ? Future<T>.error(Exception('supabase error'))
      : Future<T>.value(_response as T);
}

// Fake for the Supabase Realtime stream builder used by watchItems().
class _FakeStreamFilterBuilder extends Fake
    implements SupabaseStreamFilterBuilder {
  final Stream<List<_Row>> _inner;

  _FakeStreamFilterBuilder(this._inner);

  @override
  SupabaseStreamFilterBuilder eq(String column, Object value) => this;

  @override
  StreamSubscription<List<_Row>> listen(
    void Function(List<_Row>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _inner.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  @override
  Stream<S> map<S>(S Function(List<_Row>) convert) => _inner.map(convert);
}

class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final dynamic _response;
  final bool _throws;
  final Stream<List<_Row>>? _stream;

  _FakeQueryBuilder(this._response,
      {bool throws = false, Stream<List<_Row>>? stream})
      : _throws = throws,
        _stream = stream;

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) =>
      _FakeChain<PostgrestList>(
        _response is List
            ? (_response as List).cast<PostgrestMap>()
            : <PostgrestMap>[],
        throws: _throws,
      );

  @override
  PostgrestFilterBuilder<PostgrestList> insert(dynamic values,
          {bool defaultToNull = true}) =>
      _FakeChain<PostgrestList>(
        _response is List
            ? (_response as List).cast<PostgrestMap>()
            : <PostgrestMap>[],
        throws: _throws,
      );

  @override
  PostgrestFilterBuilder<PostgrestList> update(Map<dynamic, dynamic> values,
          {bool defaultToNull = true}) =>
      _FakeChain<PostgrestList>(<PostgrestMap>[], throws: _throws);

  @override
  PostgrestFilterBuilder<PostgrestList> delete({bool defaultToNull = true}) =>
      _FakeChain<PostgrestList>(<PostgrestMap>[], throws: _throws);

  @override
  SupabaseStreamFilterBuilder stream({required List<String> primaryKey}) =>
      _FakeStreamFilterBuilder(_stream ?? Stream<List<_Row>>.empty());
}

class _QueueEntry {
  final dynamic response;
  final bool throws;
  final Stream<List<_Row>>? stream;

  _QueueEntry(this.response, {this.throws = false, this.stream});
}

class _FakeSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, List<_QueueEntry>> _queues = {};

  void enqueue(String table, dynamic response) {
    _queues.putIfAbsent(table, () => []).add(_QueueEntry(response));
  }

  void enqueueError(String table) {
    _queues.putIfAbsent(table, () => []).add(_QueueEntry(null, throws: true));
  }

  void enqueueStream(String table, Stream<List<_Row>> stream) {
    _queues.putIfAbsent(table, () => []).add(_QueueEntry(null, stream: stream));
  }

  @override
  SupabaseQueryBuilder from(String table) {
    final queue = _queues[table] ?? [];
    final entry =
        queue.isNotEmpty ? queue.removeAt(0) : _QueueEntry(<PostgrestMap>[]);
    return _FakeQueryBuilder(entry.response,
        throws: entry.throws, stream: entry.stream);
  }
}

// ─── Test helpers ─────────────────────────────────────────────────────────────

const _groupId = 'group-1';
const _table = 'shopping_list_items';

_Row _itemRow({
  String id = 'item-1',
  String groupId = _groupId,
  String information = 'Milk',
  String? quantity = '2L',
  bool isChecked = false,
}) =>
    {
      'id': id,
      'group_id': groupId,
      'information': information,
      'quantity': quantity,
      'is_checked': isChecked,
    };

SupabaseShoppingListRepository _makeRepo(_FakeSupabaseClient client) =>
    SupabaseShoppingListRepository(supabase: client, groupId: _groupId);

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late _FakeSupabaseClient client;
  late SupabaseShoppingListRepository repo;

  setUp(() {
    client = _FakeSupabaseClient();
    repo = _makeRepo(client);
  });

  // ── watchItems ──────────────────────────────────────────────────────────────

  group('watchItems', () {
    test('emits empty list when no items exist', () async {
      client.enqueueStream(_table, Stream.value(<_Row>[]));
      expect(await repo.watchItems().first, isEmpty);
    });

    test('emits mapped ShoppingListItem entities', () async {
      final row = _itemRow(
          id: 'i-1', information: 'Eggs', quantity: '12', isChecked: false);
      client.enqueueStream(_table, Stream.value([row]));

      final items = await repo.watchItems().first;
      expect(items, hasLength(1));
      expect(items.first.id, 'i-1');
      expect(items.first.groupId, _groupId);
      expect(items.first.information, 'Eggs');
      expect(items.first.quantity, '12');
      expect(items.first.isChecked, false);
    });

    test('emits multiple items', () async {
      final rows = [
        _itemRow(id: 'i-1', information: 'Milk'),
        _itemRow(id: 'i-2', information: 'Bread'),
        _itemRow(id: 'i-3', information: 'Butter'),
      ];
      client.enqueueStream(_table, Stream.value(rows));
      final items = await repo.watchItems().first;
      expect(items, hasLength(3));
    });

    test('emits checked items with isChecked = true', () async {
      final row = _itemRow(id: 'i-1', information: 'Done', isChecked: true);
      client.enqueueStream(_table, Stream.value([row]));
      final items = await repo.watchItems().first;
      expect(items.first.isChecked, true);
    });
  });

  // ── getItems ────────────────────────────────────────────────────────────────

  group('getItems', () {
    test('returns empty list when no items exist', () async {
      client.enqueue(_table, <_Row>[]);
      expect(await repo.getItems(), isEmpty);
    });

    test('returns List<ShoppingListItem> on success', () async {
      final row = _itemRow(
          id: 'i-1', information: 'Apples', quantity: '1kg', isChecked: true);
      client.enqueue(_table, [row]);

      final items = await repo.getItems();
      expect(items, hasLength(1));
      expect(items.first, isA<ShoppingListItem>());
    });

    test('maps all entity fields correctly', () async {
      final row = _itemRow(
          id: 'x-42',
          groupId: _groupId,
          information: 'Cheese',
          quantity: '300g',
          isChecked: true);
      client.enqueue(_table, [row]);

      final item = (await repo.getItems()).first;
      expect(item.id, 'x-42');
      expect(item.groupId, _groupId);
      expect(item.information, 'Cheese');
      expect(item.quantity, '300g');
      expect(item.isChecked, true);
    });

    test('returns multiple items', () async {
      final rows =
          List.generate(4, (i) => _itemRow(id: 'i-$i', information: 'Item $i'));
      client.enqueue(_table, rows);
      expect(await repo.getItems(), hasLength(4));
    });

    test('throws Exception on Supabase error', () async {
      client.enqueueError(_table);
      await expectLater(repo.getItems(), throwsA(isA<Exception>()));
    });
  });

  // ── addItem ─────────────────────────────────────────────────────────────────

  group('addItem', () {
    test('returns ShoppingListItem on success', () async {
      final row =
          _itemRow(id: 'new-1', information: 'Butter', quantity: '200g');
      client.enqueue(_table, [row]);

      final item = await repo.addItem('Butter', '200g');
      expect(item, isA<ShoppingListItem>());
    });

    test('returned item has server-assigned id', () async {
      final row =
          _itemRow(id: 'srv-uuid', information: 'Honey', quantity: '500g');
      client.enqueue(_table, [row]);

      final item = await repo.addItem('Honey', '500g');
      expect(item.id, 'srv-uuid');
    });

    test('maps information and quantity from server response', () async {
      final row = _itemRow(id: 'x', information: 'Salt', quantity: '1 bag');
      client.enqueue(_table, [row]);

      final item = await repo.addItem('Salt', '1 bag');
      expect(item.information, 'Salt');
      expect(item.quantity, '1 bag');
    });

    test('handles null quantity', () async {
      final row = _itemRow(id: 'x', information: 'Sugar', quantity: null);
      client.enqueue(_table, [row]);

      final item = await repo.addItem('Sugar', null);
      expect(item.quantity, isNull);
    });

    test('new item has groupId set', () async {
      final row = _itemRow(id: 'x', information: 'Tea', groupId: _groupId);
      client.enqueue(_table, [row]);

      final item = await repo.addItem('Tea', null);
      expect(item.groupId, _groupId);
    });

    test('throws Exception on Supabase error', () async {
      client.enqueueError(_table);
      await expectLater(repo.addItem('X', null), throwsA(isA<Exception>()));
    });
  });

  // ── updateItem ──────────────────────────────────────────────────────────────

  group('updateItem', () {
    test('completes on success', () async {
      client.enqueue(_table, null);
      await expectLater(repo.updateItem('item-1', 'Cheese', '500g'), completes);
    });

    test('completes with null quantity', () async {
      client.enqueue(_table, null);
      await expectLater(repo.updateItem('item-1', 'Pepper', null), completes);
    });

    test('throws Exception on Supabase error', () async {
      client.enqueueError(_table);
      await expectLater(
          repo.updateItem('item-1', 'Cheese', null), throwsA(isA<Exception>()));
    });
  });

  // ── toggleItem ──────────────────────────────────────────────────────────────

  group('toggleItem', () {
    test('completes when checking an item', () async {
      client.enqueue(_table, null);
      await expectLater(repo.toggleItem('item-1', true), completes);
    });

    test('completes when unchecking an item', () async {
      client.enqueue(_table, null);
      await expectLater(repo.toggleItem('item-1', false), completes);
    });

    test('throws Exception on Supabase error', () async {
      client.enqueueError(_table);
      await expectLater(
          repo.toggleItem('item-1', true), throwsA(isA<Exception>()));
    });
  });

  // ── removeItem ──────────────────────────────────────────────────────────────

  group('removeItem', () {
    test('completes on success', () async {
      client.enqueue(_table, null);
      await expectLater(repo.removeItem('item-1'), completes);
    });

    test('throws Exception on Supabase error', () async {
      client.enqueueError(_table);
      await expectLater(repo.removeItem('item-1'), throwsA(isA<Exception>()));
    });
  });

  // ── removeCheckedItems ──────────────────────────────────────────────────────

  group('removeCheckedItems', () {
    test('completes on success', () async {
      client.enqueue(_table, null);
      await expectLater(repo.removeCheckedItems(), completes);
    });

    test('throws Exception on Supabase error', () async {
      client.enqueueError(_table);
      await expectLater(repo.removeCheckedItems(), throwsA(isA<Exception>()));
    });
  });
}
