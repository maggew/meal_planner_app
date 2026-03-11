import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/repositories/supabase_user_repository.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/domain/entities/user_profile.dart';
import 'package:meal_planner/domain/exceptions/user_exception.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

// ─── Mocks ────────────────────────────────────────────────────────────────────

class MockStorageRepository extends Mock implements StorageRepository {}

// ─── Fake Supabase infrastructure ────────────────────────────────────────────

typedef _Row = Map<String, dynamic>;

class _FakeMapChain extends Fake
    implements PostgrestTransformBuilder<PostgrestMap> {
  final PostgrestMap _value;
  final bool _throws;

  _FakeMapChain(PostgrestMap value, {bool throws = false})
      : _value = value,
        _throws = throws;

  Future<PostgrestMap> _f() => _throws
      ? Future<PostgrestMap>.error(Exception('supabase error'))
      : Future.value(_value);

  @override
  Future<R> then<R>(FutureOr<R> Function(PostgrestMap) onValue,
          {Function? onError}) =>
      _f().then(onValue, onError: onError);
  @override
  Future<PostgrestMap> catchError(Function f, {bool Function(Object)? test}) =>
      _f().catchError(f, test: test);
  @override
  Future<PostgrestMap> whenComplete(FutureOr<void> Function() action) =>
      _f().whenComplete(action);
  @override
  Future<PostgrestMap> timeout(Duration d,
          {FutureOr<PostgrestMap> Function()? onTimeout}) =>
      _f().timeout(d, onTimeout: onTimeout);
  @override
  Stream<PostgrestMap> asStream() => _f().asStream();
}

class _FakeNullableMapChain extends Fake
    implements PostgrestTransformBuilder<PostgrestMap?> {
  final PostgrestMap? _value;
  final bool _throws;

  _FakeNullableMapChain(this._value, {bool throws = false}) : _throws = throws;

  Future<PostgrestMap?> _f() => _throws
      ? Future<PostgrestMap?>.error(Exception('supabase error'))
      : Future.value(_value);

  @override
  Future<R> then<R>(FutureOr<R> Function(PostgrestMap?) onValue,
          {Function? onError}) =>
      _f().then(onValue, onError: onError);
  @override
  Future<PostgrestMap?> catchError(Function f, {bool Function(Object)? test}) =>
      _f().catchError(f, test: test);
  @override
  Future<PostgrestMap?> whenComplete(FutureOr<void> Function() action) =>
      _f().whenComplete(action);
  @override
  Future<PostgrestMap?> timeout(Duration d,
          {FutureOr<PostgrestMap?> Function()? onTimeout}) =>
      _f().timeout(d, onTimeout: onTimeout);
  @override
  Stream<PostgrestMap?> asStream() => _f().asStream();
}

class _FakeListChain extends Fake
    implements PostgrestTransformBuilder<PostgrestList> {
  final PostgrestList _value;
  final bool _throws;

  _FakeListChain(List<PostgrestMap> value, {bool throws = false})
      : _value = value,
        _throws = throws;

  Future<PostgrestList> _f() => _throws
      ? Future<PostgrestList>.error(Exception('supabase error'))
      : Future.value(_value);

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
      _f().then(onValue, onError: onError);
  @override
  Future<PostgrestList> catchError(Function f, {bool Function(Object)? test}) =>
      _f().catchError(f, test: test);
  @override
  Future<PostgrestList> whenComplete(FutureOr<void> Function() action) =>
      _f().whenComplete(action);
  @override
  Future<PostgrestList> timeout(Duration d,
          {FutureOr<PostgrestList> Function()? onTimeout}) =>
      _f().timeout(d, onTimeout: onTimeout);
  @override
  Stream<PostgrestList> asStream() => _f().asStream();
}

class _FakeChain<T> extends Fake implements PostgrestFilterBuilder<T> {
  final dynamic _response;
  final bool _throws;

  _FakeChain(this._response, {bool throws = false}) : _throws = throws;

  List<PostgrestMap> get _list => _response is List
      ? (_response as List).cast<PostgrestMap>()
      : <PostgrestMap>[];

  Future<T> _f() => _throws
      ? Future<T>.error(Exception('supabase error'))
      : Future<T>.value(_response as T);

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) => this;

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) =>
      _FakeListChain(_list, throws: _throws);

  @override
  PostgrestTransformBuilder<PostgrestMap?> maybeSingle() =>
      _FakeNullableMapChain(_list.isEmpty ? null : _list.first,
          throws: _throws);

  @override
  Future<R> then<R>(FutureOr<R> Function(T) onValue, {Function? onError}) =>
      _f().then(onValue, onError: onError);
  @override
  Future<T> catchError(Function f, {bool Function(Object)? test}) =>
      _f().catchError(f, test: test);
  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _f().whenComplete(action);
  @override
  Future<T> timeout(Duration d, {FutureOr<T> Function()? onTimeout}) =>
      _f().timeout(d, onTimeout: onTimeout);
  @override
  Stream<T> asStream() => _f().asStream();
}

class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final dynamic _response;
  final bool _throws;

  _FakeQueryBuilder(this._response, {bool throws = false}) : _throws = throws;

  List<PostgrestMap> get _list => _response is List
      ? (_response as List).cast<PostgrestMap>()
      : <PostgrestMap>[];

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) =>
      _FakeChain<PostgrestList>(_list, throws: _throws);

  @override
  PostgrestFilterBuilder<PostgrestList> insert(dynamic values,
          {bool defaultToNull = true}) =>
      _FakeChain<PostgrestList>(_list, throws: _throws);

  @override
  PostgrestFilterBuilder<PostgrestList> update(Map<dynamic, dynamic> values,
          {bool defaultToNull = true}) =>
      _FakeChain<PostgrestList>(<PostgrestMap>[], throws: _throws);

  @override
  PostgrestFilterBuilder<PostgrestList> delete({bool defaultToNull = true}) =>
      _FakeChain<PostgrestList>(<PostgrestMap>[], throws: _throws);
}

class _FakeSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, List<dynamic>> _queues = {};

  void enqueue(String table, dynamic response) {
    _queues.putIfAbsent(table, () => []).add(response);
  }

  void enqueueError(String table) {
    _queues.putIfAbsent(table, () => []).add(_Error());
  }

  @override
  SupabaseQueryBuilder from(String table) {
    final queue = _queues[table] ?? [];
    final entry = queue.isNotEmpty ? queue.removeAt(0) : <PostgrestMap>[];
    if (entry is _Error) return _FakeQueryBuilder(null, throws: true);
    return _FakeQueryBuilder(entry);
  }
}

class _Error {}

// ─── Test helpers ─────────────────────────────────────────────────────────────

const _uid = 'user-1';
const _users = 'users';
const _groupMembers = 'group_members';

_Row _userRow({
  String id = _uid,
  String name = 'Alice',
  String? imageUrl,
}) =>
    {
      'id': id,
      'name': name,
      'image_url': imageUrl,
    };

_Row _userProfileRow({
  String id = _uid,
  String name = 'Alice',
  String? imageUrl,
  String email = 'alice@test.com',
  String createdAt = '2024-01-01T00:00:00.000Z',
}) =>
    {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'email': email,
      'created_at': createdAt,
    };

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late _FakeSupabaseClient supabase;
  late MockStorageRepository storage;
  late SupabaseUserRepository repo;

  setUpAll(() {
    registerFallbackValue(File(''));
  });

  setUp(() {
    supabase = _FakeSupabaseClient();
    storage = MockStorageRepository();
    repo = SupabaseUserRepository(supabase: supabase, storage: storage);
  });

  // ── createUser ──────────────────────────────────────────────────────────────

  group('createUser', () {
    test('completes on success', () async {
      supabase.enqueue(_users, null);
      await expectLater(repo.createUser(uid: _uid, name: 'Alice'), completes);
    });

    test('throws UserCreationException on error', () async {
      supabase.enqueueError(_users);
      await expectLater(repo.createUser(uid: _uid, name: 'Alice'),
          throwsA(isA<UserCreationException>()));
    });
  });

  // ── getUserById ─────────────────────────────────────────────────────────────

  group('getUserById', () {
    test('returns User with correct fields', () async {
      supabase
          .enqueue(_users, [_userRow(id: 'u-1', name: 'Bob', imageUrl: 'url')]);
      final user = await repo.getUserById('u-1');
      expect(user, isA<User>());
      expect(user!.id, 'u-1');
      expect(user.name, 'Bob');
      expect(user.imageUrl, 'url');
    });

    test('returns null when user not found', () async {
      supabase.enqueue(_users, <_Row>[]);
      final user = await repo.getUserById('nonexistent');
      expect(user, isNull);
    });

    test('throws UserNotFoundException on error', () async {
      supabase.enqueueError(_users);
      await expectLater(
          repo.getUserById('u-1'), throwsA(isA<UserNotFoundException>()));
    });
  });

  // ── getUserProfileById ──────────────────────────────────────────────────────

  group('getUserProfileById', () {
    test('returns UserProfile with correct fields', () async {
      supabase.enqueue(_users, [
        _userProfileRow(
          id: 'u-1',
          name: 'Carol',
          email: 'carol@test.com',
          createdAt: '2023-06-15T12:00:00.000Z',
        )
      ]);
      final profile = await repo.getUserProfileById('u-1');
      expect(profile, isA<UserProfile>());
      expect(profile!.id, 'u-1');
      expect(profile.name, 'Carol');
      expect(profile.email, 'carol@test.com');
      expect(profile.createdAt, DateTime.parse('2023-06-15T12:00:00.000Z'));
    });

    test('returns null when user not found', () async {
      supabase.enqueue(_users, <_Row>[]);
      final profile = await repo.getUserProfileById('nonexistent');
      expect(profile, isNull);
    });

    test('throws UserNotFoundException on error', () async {
      supabase.enqueueError(_users);
      await expectLater(repo.getUserProfileById('u-1'),
          throwsA(isA<UserNotFoundException>()));
    });
  });

  // ── getUserByFirebaseUid ────────────────────────────────────────────────────

  group('getUserByFirebaseUid', () {
    test('returns User when found', () async {
      supabase.enqueue(_users, [_userRow(id: _uid, name: 'Dave')]);
      final user = await repo.getUserByFirebaseUid('firebase-uid-1');
      expect(user, isA<User>());
      expect(user!.name, 'Dave');
    });

    test('returns null when not found', () async {
      supabase.enqueue(_users, <_Row>[]);
      final user = await repo.getUserByFirebaseUid('firebase-uid-1');
      expect(user, isNull);
    });

    test('returns null on error (swallows exception silently)', () async {
      supabase.enqueueError(_users);
      final user = await repo.getUserByFirebaseUid('firebase-uid-1');
      expect(user, isNull);
    });
  });

  // ── updateUser ──────────────────────────────────────────────────────────────

  group('updateUser', () {
    test('completes on success', () async {
      supabase.enqueue(_users, null);
      final user = User(id: _uid, name: 'Eve');
      await expectLater(repo.updateUser(user), completes);
    });

    test('throws UserUpdateException on error', () async {
      supabase.enqueueError(_users);
      final user = User(id: _uid, name: 'Eve');
      await expectLater(
          repo.updateUser(user), throwsA(isA<UserUpdateException>()));
    });
  });

  // ── getGroupIds ─────────────────────────────────────────────────────────────

  group('getGroupIds', () {
    test('returns list of group ids', () async {
      supabase.enqueue(_groupMembers, [
        {'group_id': 'g-1'},
        {'group_id': 'g-2'},
      ]);
      final ids = await repo.getGroupIds(_uid);
      expect(ids, ['g-1', 'g-2']);
    });

    test('returns empty list when no memberships', () async {
      supabase.enqueue(_groupMembers, <_Row>[]);
      final ids = await repo.getGroupIds(_uid);
      expect(ids, isEmpty);
    });

    test('throws UserNotFoundException on error', () async {
      supabase.enqueueError(_groupMembers);
      await expectLater(
          repo.getGroupIds(_uid), throwsA(isA<UserNotFoundException>()));
    });
  });

  // ── updateUserImage ─────────────────────────────────────────────────────────

  group('updateUserImage', () {
    test('completes on success', () async {
      supabase.enqueue(_users, null);
      await expectLater(
          repo.updateUserImage(uid: _uid, imageUrl: 'https://img.test/new.jpg'),
          completes);
    });

    test('throws UserUpdateException on error', () async {
      supabase.enqueueError(_users);
      await expectLater(
          repo.updateUserImage(uid: _uid, imageUrl: 'https://img.test/new.jpg'),
          throwsA(isA<UserUpdateException>()));
    });
  });

  // ── updateUserProfile ───────────────────────────────────────────────────────

  group('updateUserProfile', () {
    test('updates name only when image is null', () async {
      supabase.enqueue(_users, null); // update call
      when(() => storage.uploadImage(any(), any()))
          .thenAnswer((_) async => 'https://new.img');

      await expectLater(
          repo.updateUserProfile(userId: _uid, image: null, name: 'Alice'),
          completes);
      verifyNever(() => storage.uploadImage(any(), any()));
    });

    test('uploads image, updates user, deletes old image when old URL exists',
        () async {
      when(() => storage.uploadImage(any(), any()))
          .thenAnswer((_) async => 'https://new.img/photo.jpg');
      when(() => storage.deleteImage(any())).thenAnswer((_) async {});

      // First call: maybeSingle for old image URL
      supabase.enqueue(_users, [
        {'id': _uid, 'name': 'Alice', 'image_url': 'https://old.img/photo.jpg'}
      ]);
      // Second call: update
      supabase.enqueue(_users, null);

      await repo.updateUserProfile(
          userId: _uid, image: File('test.jpg'), name: 'Alice');

      verify(() => storage.uploadImage(any(), any())).called(1);
      // deleteImage is fire-and-forget (not awaited), verify it was scheduled
      verify(() => storage.deleteImage('https://old.img/photo.jpg')).called(1);
    });

    test('does not delete image when no old image URL exists', () async {
      when(() => storage.uploadImage(any(), any()))
          .thenAnswer((_) async => 'https://new.img/photo.jpg');
      when(() => storage.deleteImage(any())).thenAnswer((_) async {});

      // maybeSingle returns row with null image_url
      supabase.enqueue(_users, [
        {'id': _uid, 'name': 'Alice', 'image_url': null}
      ]);
      supabase.enqueue(_users, null); // update

      await repo.updateUserProfile(
          userId: _uid, image: File('test.jpg'), name: 'Alice');

      verifyNever(() => storage.deleteImage(any()));
    });

    test('throws UserUpdateException when upload fails', () async {
      when(() => storage.uploadImage(any(), any()))
          .thenThrow(Exception('upload failed'));

      await expectLater(
          repo.updateUserProfile(
              userId: _uid, image: File('test.jpg'), name: 'Alice'),
          throwsA(isA<UserUpdateException>()));
    });

    test('throws UserUpdateException when old-image-fetch fails', () async {
      when(() => storage.uploadImage(any(), any()))
          .thenAnswer((_) async => 'https://new.img/photo.jpg');
      // Upload succeeds but Supabase select for old image throws
      supabase.enqueueError(_users);

      await expectLater(
          repo.updateUserProfile(
              userId: _uid, image: File('test.jpg'), name: 'Alice'),
          throwsA(isA<UserUpdateException>()));
    });

    test('throws UserUpdateException when Supabase update fails', () async {
      when(() => storage.uploadImage(any(), any()))
          .thenAnswer((_) async => 'https://new.img/photo.jpg');
      // maybeSingle for old image succeeds
      supabase.enqueue(_users, [
        {'id': _uid, 'name': 'Alice', 'image_url': null}
      ]);
      // update call fails
      supabase.enqueueError(_users);

      await expectLater(
          repo.updateUserProfile(
              userId: _uid, image: File('test.jpg'), name: 'Alice'),
          throwsA(isA<UserUpdateException>()));
    });
  });
}
