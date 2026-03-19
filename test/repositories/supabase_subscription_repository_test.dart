import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/repositories/supabase_subscription_repository.dart';
import 'package:meal_planner/domain/enums/subscription_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==================== Supabase Fakes ====================

/// Resolves as Map<String, dynamic>? for maybeSingle().
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

/// Resolves as List<Map<String, dynamic>>.
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

/// Allgemeiner Filter-Fake.
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
}

class _FakeSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, List<dynamic>> _queues = {};

  void enqueue(String table, dynamic response) {
    _queues.putIfAbsent(table, () => []).add(response);
  }

  @override
  SupabaseQueryBuilder from(String table) {
    final queue = _queues[table] ?? [];
    final response = queue.isNotEmpty ? queue.removeAt(0) : <PostgrestMap>[];
    return _FakeQueryBuilder(response);
  }
}

// ==================== Tests ====================

const _kGroupId = 'gruppe-1';

Map<String, dynamic> _subscriptionRow({
  String groupId = _kGroupId,
  String status = 'free',
  String? subscriberUserId,
  String? productId,
  String? expiresAt,
  String? updatedAt,
}) =>
    {
      'group_id': groupId,
      'status': status,
      if (subscriberUserId != null) 'subscriber_user_id': subscriberUserId,
      if (productId != null) 'product_id': productId,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };

void main() {
  group('getSubscription', () {
    test('gibt free zurück wenn kein Eintrag existiert', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('subscriptions', <PostgrestMap>[]);
      final repo = SupabaseSubscriptionRepository(supabase: supabase);

      final result = await repo.getSubscription(_kGroupId);

      expect(result.groupId, _kGroupId);
      expect(result.status, SubscriptionStatus.free);
      expect(result.isPremium, false);
    });

    test('gibt korrekten Status zurück bei vorhandenem Eintrag', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('subscriptions', [
          _subscriptionRow(status: 'premium'),
        ]);
      final repo = SupabaseSubscriptionRepository(supabase: supabase);

      final result = await repo.getSubscription(_kGroupId);

      expect(result.status, SubscriptionStatus.premium);
      expect(result.isPremium, true);
    });

    test('parst expiresAt korrekt', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('subscriptions', [
          _subscriptionRow(
            status: 'premium',
            expiresAt: '2026-12-31T23:59:59.000Z',
          ),
        ]);
      final repo = SupabaseSubscriptionRepository(supabase: supabase);

      final result = await repo.getSubscription(_kGroupId);

      expect(result.expiresAt, isNotNull);
      expect(result.expiresAt!.year, 2026);
      expect(result.expiresAt!.month, 12);
    });

    test('gibt free zurück bei status=free', () async {
      final supabase = _FakeSupabaseClient()
        ..enqueue('subscriptions', [
          _subscriptionRow(status: 'free'),
        ]);
      final repo = SupabaseSubscriptionRepository(supabase: supabase);

      final result = await repo.getSubscription(_kGroupId);

      expect(result.status, SubscriptionStatus.free);
      expect(result.isPremium, false);
    });
  });
}
