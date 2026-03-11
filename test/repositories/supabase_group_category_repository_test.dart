import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/repositories/supabase_group_category_repository.dart';
import 'package:meal_planner/domain/entities/group_category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==================== Supabase Fakes ====================
//
// Wie in den anderen Offline-First-Tests: SupabaseClient wird hand-gefaked,
// weil PostgrestBuilder implements Future<T> und mocktail dafür nicht geeignet
// ist. Hier kommt eine Queue-basierte Variante, da einzelne Methoden denselben
// Table mehrfach abfragen (z.B. addCategory: erst count, dann insert).

/// Terminaler Fake für .single() — resolves as Map<String, dynamic>.
class _FakeMapChain extends Fake
    implements PostgrestTransformBuilder<PostgrestMap> {
  final PostgrestMap _value;

  _FakeMapChain(Map<String, dynamic> value) : _value = value;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestMap) onValue, {
    Function? onError,
  }) =>
      Future.value(_value).then(onValue, onError: onError);

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

/// Fake für .select() — resolves as List<Map<String, dynamic>>.
/// Unterstützt .order() und .single() für Folge-Operationen.
class _FakeListChain extends Fake
    implements PostgrestTransformBuilder<PostgrestList> {
  final PostgrestList _value;
  final PostgrestMap _singleValue;

  _FakeListChain(List<Map<String, dynamic>> value, {PostgrestMap? singleValue})
      : _value = value,
        _singleValue = singleValue ?? (value.isNotEmpty ? value.first : {});

  @override
  PostgrestTransformBuilder<PostgrestList> order(
    String column, {
    bool ascending = true,
    bool nullsFirst = false,
    String? referencedTable,
  }) =>
      this;

  @override
  PostgrestTransformBuilder<PostgrestMap> single() =>
      _FakeMapChain(_singleValue);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestList) onValue, {
    Function? onError,
  }) =>
      Future.value(_value).then(onValue, onError: onError);

  @override
  Future<PostgrestList> catchError(Function f, {bool Function(Object)? test}) =>
      Future.value(_value).catchError(f, test: test);

  @override
  Future<PostgrestList> whenComplete(FutureOr<void> Function() action) =>
      Future.value(_value).whenComplete(action);

  @override
  Future<PostgrestList> timeout(
    Duration d, {
    FutureOr<PostgrestList> Function()? onTimeout,
  }) =>
      Future.value(_value).timeout(d, onTimeout: onTimeout);

  @override
  Stream<PostgrestList> asStream() => Stream.value(_value);
}

/// Allgemeiner Filter-Fake — resolves as T.
/// Unterstützt eq(), order(), select() und upsert()-ähnliche Chains.
class _FakeChain<T> extends Fake implements PostgrestFilterBuilder<T> {
  final dynamic _response;

  _FakeChain([this._response]);

  // ── Chainable filter methods ──────────────────────────────────────────────

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<T> order(
    String column, {
    bool ascending = true,
    bool nullsFirst = false,
    String? referencedTable,
  }) =>
      this;

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) {
    final list = _response is List
        ? (_response as List).cast<PostgrestMap>()
        : <PostgrestMap>[];
    return _FakeListChain(list);
  }

  // ── Future<T> implementation ──────────────────────────────────────────────

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T) onValue, {
    Function? onError,
  }) =>
      Future<T>.value(_response as T).then(onValue, onError: onError);

  @override
  Future<T> catchError(Function f, {bool Function(Object)? test}) =>
      Future<T>.value(_response as T).catchError(f, test: test);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      Future<T>.value(_response as T).whenComplete(action);

  @override
  Future<T> timeout(
    Duration d, {
    FutureOr<T> Function()? onTimeout,
  }) =>
      Future<T>.value(_response as T).timeout(d, onTimeout: onTimeout);

  @override
  Stream<T> asStream() => Stream<T>.value(_response as T);
}

/// Fake SupabaseQueryBuilder — liefert vorkonfigurierte Responses.
class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final dynamic _response;

  _FakeQueryBuilder([this._response]);

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) =>
      _FakeChain<PostgrestList>(_response is List
          ? (_response as List).cast<PostgrestMap>()
          : <PostgrestMap>[]);

  @override
  PostgrestFilterBuilder<PostgrestList> insert(
    dynamic values, {
    bool defaultToNull = true,
  }) =>
      _FakeChain<PostgrestList>(_response is List
          ? (_response as List).cast<PostgrestMap>()
          : <PostgrestMap>[]);

  @override
  PostgrestFilterBuilder<PostgrestList> update(
    Map<dynamic, dynamic> values, {
    bool defaultToNull = true,
  }) =>
      _FakeChain<PostgrestList>(_response is List
          ? (_response as List).cast<PostgrestMap>()
          : <PostgrestMap>[]);

  @override
  PostgrestFilterBuilder<PostgrestList> delete({bool defaultToNull = true}) =>
      _FakeChain<PostgrestList>(<PostgrestMap>[]);

  @override
  PostgrestFilterBuilder<PostgrestList> upsert(
    dynamic values, {
    bool defaultToNull = true,
    String? onConflict,
    bool ignoreDuplicates = false,
  }) =>
      _FakeChain<PostgrestList>(<PostgrestMap>[]);
}

/// Top-level Fake für SupabaseClient.
///
/// Jede Tabelle hat eine eigene Response-Queue. Jeder `from(table)`-Aufruf
/// entnimmt die nächste Response aus der Queue dieser Tabelle.
/// `tableCalls` protokolliert die Reihenfolge der Zugriffe für
/// Reihenfolge-Assertions.
class _FakeSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, List<dynamic>> _queues = {};
  final List<String> tableCalls = [];

  /// Fügt eine Response für den nächsten `from(table)`-Aufruf hinzu.
  void enqueue(String table, dynamic response) {
    _queues.putIfAbsent(table, () => []).add(response);
  }

  @override
  SupabaseQueryBuilder from(String table) {
    tableCalls.add(table);
    final queue = _queues[table] ?? [];
    final response = queue.isNotEmpty ? queue.removeAt(0) : <PostgrestMap>[];
    return _FakeQueryBuilder(response);
  }
}

// ==================== Helpers ====================

const _kGroupId = 'gruppe-1';

GroupCategory _fakeCategory({
  String id = 'cat-1',
  String groupId = _kGroupId,
  String name = 'Pasta',
  int sortOrder = 0,
  String? iconName,
}) =>
    GroupCategory(
      id: id,
      groupId: groupId,
      name: name,
      sortOrder: sortOrder,
      iconName: iconName,
    );

// Supabase-Response-Map für eine GroupCategory
Map<String, dynamic> _categoryRow({
  String id = 'cat-1',
  String groupId = _kGroupId,
  String name = 'Pasta',
  int sortOrder = 0,
  String? iconName,
}) =>
    {
      'id': id,
      'group_id': groupId,
      'name': name,
      'sort_order': sortOrder,
      if (iconName != null) 'icon_name': iconName,
    };

SupabaseGroupCategoryRepository _buildRepo(_FakeSupabaseClient supabase) {
  return SupabaseGroupCategoryRepository(supabase: supabase);
}

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // CategoryInUseException
  // ═══════════════════════════════════════════════════════════════════════════

  group('CategoryInUseException', () {
    test('toString gibt korrekte Meldung mit recipeCount zurück', () {
      expect(
        CategoryInUseException(3).toString(),
        '3 Rezepte verwenden diese Kategorie',
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 1 — getCategories
  // ═══════════════════════════════════════════════════════════════════════════

  group('getCategories', () {
    test('1 — gibt gemappte GroupCategory-Liste mit korrekten Feldern zurück',
        () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', [
          _categoryRow(id: 'c1', name: 'Pasta', sortOrder: 0),
          _categoryRow(id: 'c2', name: 'Salat', sortOrder: 1),
        ]);
      final repo = _buildRepo(supabase);

      final result = await repo.getCategories(_kGroupId);

      expect(result, hasLength(2));
      expect(result.first.id, 'c1');
      expect(result.first.name, 'Pasta');
      expect(result.first.sortOrder, 0);
      expect(result.last.id, 'c2');
    });

    test('2 — gibt leere Liste zurück wenn keine Kategorien vorhanden',
        () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', <PostgrestMap>[]);
      final repo = _buildRepo(supabase);

      final result = await repo.getCategories(_kGroupId);

      expect(result, isEmpty);
    });

    test('3 — Gruppen-Isolation: fragt mit der übergebenen groupId ab',
        () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', <PostgrestMap>[]);
      final repo = _buildRepo(supabase);

      await repo.getCategories('andere-gruppe');

      // Einmal from('categories') aufgerufen — keine weiteren fremden Tabellen
      expect(supabase.tableCalls, ['categories']);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 2 — addCategory
  // ═══════════════════════════════════════════════════════════════════════════

  group('addCategory', () {
    test('4 — gibt erstellte GroupCategory mit korrekten Feldern zurück',
        () async {
      final createdRow = _categoryRow(
          id: 'new-cat', name: 'Dessert', sortOrder: 0, iconName: 'cake');
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', <PostgrestMap>[]) // count-Query: 0 bestehende
        ..enqueue('categories', [createdRow]); // insert → select().single()
      final repo = _buildRepo(supabase);

      final result =
          await repo.addCategory(_kGroupId, 'Dessert', iconName: 'cake');

      expect(result.id, 'new-cat');
      expect(result.name, 'Dessert');
      expect(result.iconName, 'cake');
    });

    test('5 — sortOrder = 0 wenn keine bestehenden Kategorien', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', <PostgrestMap>[]) // 0 bestehende
        ..enqueue('categories', [_categoryRow(sortOrder: 0)]); // insert result
      final repo = _buildRepo(supabase);

      final result = await repo.addCategory(_kGroupId, 'Neu');

      expect(result.sortOrder, 0);
    });

    test('6 — sortOrder = n wenn n bestehende Kategorien vorhanden', () async {
      // 3 bestehende Kategorien → neue bekommt sortOrder=3
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', [
          _categoryRow(id: 'c1'),
          _categoryRow(id: 'c2'),
          _categoryRow(id: 'c3'),
        ]) // count-Query: 3 bestehende
        ..enqueue('categories', [_categoryRow(sortOrder: 3)]); // insert result
      final repo = _buildRepo(supabase);

      final result = await repo.addCategory(_kGroupId, 'Vierte');

      expect(result.sortOrder, 3);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 3 — updateCategory
  // ═══════════════════════════════════════════════════════════════════════════

  group('updateCategory', () {
    test('7 — kein Supabase-Aufruf wenn alle Parameter null (early return)',
        () async {
      final supabase = _FakeSupabaseClient();
      final repo = _buildRepo(supabase);

      await repo.updateCategory('cat-1');

      expect(supabase.tableCalls, isEmpty);
    });

    test('8 — kein Fehler bei erfolgreichem Update', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', [_categoryRow()]); // non-empty response
      final repo = _buildRepo(supabase);

      await expectLater(
        repo.updateCategory('cat-1', name: 'Neuer Name'),
        completes,
      );
    });

    test(
        '9 — wirft Exception wenn kein Row aktualisiert wurde (leere Response)',
        () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', <PostgrestMap>[]); // leere Antwort
      final repo = _buildRepo(supabase);

      await expectLater(
        repo.updateCategory('cat-1', name: 'Neuer Name'),
        throwsA(isA<Exception>()),
      );
    });

    test('10 — sortOrder != null wird in data aufgenommen', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', [_categoryRow()]);
      final repo = _buildRepo(supabase);

      await expectLater(
        repo.updateCategory('cat-1', sortOrder: 2),
        completes,
      );
    });

    test('11 — iconName != null wird in data aufgenommen', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', [_categoryRow()]);
      final repo = _buildRepo(supabase);

      await expectLater(
        repo.updateCategory('cat-1', iconName: 'pizza'),
        completes,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 4 — updateSortOrders
  // ═══════════════════════════════════════════════════════════════════════════

  group('updateSortOrders', () {
    test('10 — kein Fehler bei korrekten Eingaben', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', <PostgrestMap>[]);
      final repo = _buildRepo(supabase);

      await expectLater(
        repo.updateSortOrders([
          _fakeCategory(id: 'c1', sortOrder: 0),
          _fakeCategory(id: 'c2', sortOrder: 1),
        ]),
        completes,
      );
    });

    test('11 — kein Fehler bei leerer Liste', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', <PostgrestMap>[]);
      final repo = _buildRepo(supabase);

      await expectLater(repo.updateSortOrders([]), completes);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 5 — deleteCategory
  // ═══════════════════════════════════════════════════════════════════════════

  group('deleteCategory', () {
    test('12 — löscht Kategorie erfolgreich wenn keine Rezepte sie verwenden',
        () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('recipe_categories', <PostgrestMap>[]) // 0 Verwendungen
        ..enqueue('categories', <PostgrestMap>[]); // delete
      final repo = _buildRepo(supabase);

      await expectLater(repo.deleteCategory('cat-1'), completes);
    });

    test('13 — wirft CategoryInUseException mit korrektem recipeCount',
        () async {
      // 2 Rezepte verwenden die Kategorie
      final supabase = _FakeSupabaseClient()
        ..enqueue('recipe_categories', [
          {'recipe_id': 'r1'},
          {'recipe_id': 'r2'},
        ]);
      final repo = _buildRepo(supabase);

      await expectLater(
        repo.deleteCategory('cat-1'),
        throwsA(
          isA<CategoryInUseException>()
              .having((e) => e.recipeCount, 'recipeCount', 2),
        ),
      );
    });

    test(
        '14 — CategoryInUseException.recipeCount entspricht tatsächlicher Anzahl',
        () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue(
            'recipe_categories',
            List.generate(
              5,
              (i) => {'recipe_id': 'r$i'},
            ));
      final repo = _buildRepo(supabase);

      expect(
        () => repo.deleteCategory('cat-x'),
        throwsA(
          isA<CategoryInUseException>()
              .having((e) => e.recipeCount, 'recipeCount', 5),
        ),
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Gruppe 6 — syncCategories
  // ═══════════════════════════════════════════════════════════════════════════

  group('syncCategories', () {
    test('15 — löscht alle IDs aus deletedIds', () async {
      // 2 zu löschende Kategorien: je 1 recipe_categories-Check + 1 delete
      final supabase = _FakeSupabaseClient()
        ..enqueue('recipe_categories', <PostgrestMap>[]) // check cat-1
        ..enqueue('categories', <PostgrestMap>[]) // delete cat-1
        ..enqueue('recipe_categories', <PostgrestMap>[]) // check cat-2
        ..enqueue('categories', <PostgrestMap>[]); // delete cat-2
      // keine categories zum upserten
      final repo = _buildRepo(supabase);

      await repo.syncCategories(_kGroupId, [], ['cat-1', 'cat-2']);

      // 2x recipe_categories (usage check) + 2x categories (delete)
      expect(
        supabase.tableCalls.where((t) => t == 'recipe_categories').length,
        2,
      );
      expect(
        supabase.tableCalls.where((t) => t == 'categories').length,
        2,
      );
    });

    test(
        '16 — propagiert CategoryInUseException wenn eine zu löschende Kategorie in Verwendung ist',
        () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('recipe_categories', [
          {'recipe_id': 'r1'}
        ]); // cat-1 in Verwendung
      final repo = _buildRepo(supabase);

      await expectLater(
        repo.syncCategories(_kGroupId, [], ['cat-1']),
        throwsA(isA<CategoryInUseException>()),
      );
    });

    test('17 — upserted alle übergebenen categories', () async {
      // keine deletedIds, aber 2 categories → 1 upsert
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', <PostgrestMap>[]);
      final repo = _buildRepo(supabase);

      await repo.syncCategories(
        _kGroupId,
        [
          _fakeCategory(id: 'c1', name: 'Pasta'),
          _fakeCategory(id: 'c2', name: 'Salat'),
        ],
        [],
      );

      expect(supabase.tableCalls, ['categories']); // 1x upsert
    });

    test('18 — leere deletedIds: kein Delete-Aufruf, kein Fehler', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('categories', <PostgrestMap>[]);
      final repo = _buildRepo(supabase);

      await expectLater(
        repo.syncCategories(_kGroupId, [_fakeCategory()], []),
        completes,
      );

      // Kein recipe_categories-Zugriff (kein Löschvorgang)
      expect(
          supabase.tableCalls.where((t) => t == 'recipe_categories'), isEmpty);
    });

    test('19 — leere categories: kein Upsert-Aufruf, kein Fehler', () async {
      // 1 deletedId: 1 check + 1 delete, dann kein upsert
      final supabase = _FakeSupabaseClient()
        ..enqueue('recipe_categories', <PostgrestMap>[])
        ..enqueue('categories', <PostgrestMap>[]);
      final repo = _buildRepo(supabase);

      await expectLater(
        repo.syncCategories(_kGroupId, [], ['cat-1']),
        completes,
      );

      // categories wurde nur für den delete aufgerufen, kein zweiter upsert-Call
      expect(
        supabase.tableCalls.where((t) => t == 'categories').length,
        1,
      );
    });

    test(
        '20 — zweites deletedId wirft CategoryInUseException, erstes wurde bereits gelöscht',
        () async {
      // cat-1: 0 Verwendungen → delete
      // cat-2: 1 Verwendung → CategoryInUseException
      final supabase = _FakeSupabaseClient()
        ..enqueue('recipe_categories', <PostgrestMap>[]) // cat-1 usage: 0
        ..enqueue('categories', <PostgrestMap>[]) // cat-1 delete
        ..enqueue('recipe_categories', [
          {'recipe_id': 'r1'}
        ]); // cat-2 usage: 1
      final repo = _buildRepo(supabase);

      await expectLater(
        repo.syncCategories(_kGroupId, [], ['cat-1', 'cat-2']),
        throwsA(isA<CategoryInUseException>()),
      );

      // cat-1 delete wurde bereits durchgeführt (2 categories-Aufrufe bis zur Exception)
      expect(
        supabase.tableCalls.where((t) => t == 'categories').length,
        1,
      );
    });
  });
}
