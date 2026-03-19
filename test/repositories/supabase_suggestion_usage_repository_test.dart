import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/repositories/supabase_suggestion_usage_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==================== Supabase Fakes ====================

class _FakeNullableMapChain extends Fake
    implements PostgrestTransformBuilder<PostgrestMap?> {
  final PostgrestMap? _value;

  _FakeNullableMapChain(this._value);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestMap?) onValue, {
    Function? onError,
  }) =>
      Future.value(_value).then(onValue, onError: onError);

  @override
  Future<PostgrestMap?> catchError(Function f,
          {bool Function(Object)? test}) =>
      Future.value(_value).catchError(f, test: test);

  @override
  Future<PostgrestMap?> whenComplete(FutureOr<void> Function() action) =>
      Future.value(_value).whenComplete(action);

  @override
  Stream<PostgrestMap?> asStream() => Stream.value(_value);
}

class _FakeListChain extends Fake
    implements PostgrestTransformBuilder<PostgrestList> {
  final PostgrestList _value;

  _FakeListChain(List<Map<String, dynamic>> value) : _value = value;

  @override
  PostgrestTransformBuilder<PostgrestMap?> maybeSingle() =>
      _FakeNullableMapChain(_value.isNotEmpty ? _value.first : null);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestList) onValue, {
    Function? onError,
  }) =>
      Future.value(_value).then(onValue, onError: onError);

  @override
  Future<PostgrestList> catchError(Function f,
          {bool Function(Object)? test}) =>
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

class _FakeChain<T> extends Fake implements PostgrestFilterBuilder<T> {
  final dynamic _response;

  _FakeChain([this._response]);

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) => this;

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) {
    final list = _response is List
        ? (_response as List).cast<PostgrestMap>()
        : <PostgrestMap>[];
    return _FakeListChain(list);
  }

  @override
  PostgrestTransformBuilder<PostgrestMap?> maybeSingle() {
    final list = _response is List
        ? (_response as List).cast<PostgrestMap>()
        : <PostgrestMap>[];
    return _FakeNullableMapChain(list.isNotEmpty ? list.first : null);
  }

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

class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final dynamic _response;

  _FakeQueryBuilder([this._response]);

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) =>
      _FakeChain<PostgrestList>(_response is List
          ? (_response as List).cast<PostgrestMap>()
          : <PostgrestMap>[]);

  @override
  PostgrestFilterBuilder<PostgrestList> update(
    Map<dynamic, dynamic> values, {
    bool defaultToNull = true,
  }) =>
      _FakeChain<PostgrestList>(<PostgrestMap>[]);

  @override
  PostgrestFilterBuilder<PostgrestList> insert(
    dynamic values, {
    bool defaultToNull = true,
  }) =>
      _FakeChain<PostgrestList>(<PostgrestMap>[]);
}

class _FakeSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, List<dynamic>> _queues = {};
  final List<String> tableCalls = [];

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

// ==================== Tests ====================

const _kGroupId = 'gruppe-1';

Map<String, dynamic> _usageRow({
  String id = 'usage-1',
  String groupId = _kGroupId,
  int weekYear = 2026,
  int weekNumber = 12,
  int usageCount = 0,
}) =>
    {
      'id': id,
      'group_id': groupId,
      'week_year': weekYear,
      'week_number': weekNumber,
      'usage_count': usageCount,
    };

void main() {
  group('getCurrentWeekUsage', () {
    test('gibt usageCount=0 wenn kein Eintrag existiert', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('suggestion_usage', <PostgrestMap>[]);
      final repo = SupabaseSuggestionUsageRepository(supabase: supabase);

      final result = await repo.getCurrentWeekUsage(_kGroupId);

      expect(result.groupId, _kGroupId);
      expect(result.usageCount, 0);
    });

    test('gibt korrekten usageCount zurück bei vorhandenem Eintrag', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('suggestion_usage', [_usageRow(usageCount: 2)]);
      final repo = SupabaseSuggestionUsageRepository(supabase: supabase);

      final result = await repo.getCurrentWeekUsage(_kGroupId);

      expect(result.usageCount, 2);
    });

    test('gibt korrekte ISO-Woche zurück', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('suggestion_usage', <PostgrestMap>[]);
      final repo = SupabaseSuggestionUsageRepository(supabase: supabase);

      final result = await repo.getCurrentWeekUsage(_kGroupId);

      expect(result.weekYear, greaterThan(0));
      expect(result.weekNumber, greaterThan(0));
      expect(result.weekNumber, lessThanOrEqualTo(53));
    });
  });

  group('incrementUsage', () {
    test('erstellt neuen Eintrag wenn keiner existiert', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('suggestion_usage', <PostgrestMap>[]) // maybeSingle → null
        ..enqueue('suggestion_usage', <PostgrestMap>[]); // insert
      final repo = SupabaseSuggestionUsageRepository(supabase: supabase);

      await expectLater(repo.incrementUsage(_kGroupId), completes);

      // 2 Aufrufe: 1x select (check), 1x insert
      expect(
        supabase.tableCalls.where((t) => t == 'suggestion_usage').length,
        2,
      );
    });

    test('erhöht usageCount wenn Eintrag existiert', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('suggestion_usage', [_usageRow(usageCount: 1)]) // existing
        ..enqueue('suggestion_usage', <PostgrestMap>[]); // update
      final repo = SupabaseSuggestionUsageRepository(supabase: supabase);

      await expectLater(repo.incrementUsage(_kGroupId), completes);

      // 2 Aufrufe: 1x select (find existing), 1x update
      expect(
        supabase.tableCalls.where((t) => t == 'suggestion_usage').length,
        2,
      );
    });
  });

  group('isoWeek', () {
    // Indirekt über getCurrentWeekUsage getestet — die Methode setzt
    // weekYear und weekNumber basierend auf DateTime.now().
    // Wir verifizieren nur, dass die Werte plausibel sind.
    test('weekNumber liegt zwischen 1 und 53', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('suggestion_usage', <PostgrestMap>[]);
      final repo = SupabaseSuggestionUsageRepository(supabase: supabase);

      final result = await repo.getCurrentWeekUsage(_kGroupId);

      expect(result.weekNumber, inInclusiveRange(1, 53));
      expect(result.weekYear, inInclusiveRange(2020, 2099));
    });
  });
}
