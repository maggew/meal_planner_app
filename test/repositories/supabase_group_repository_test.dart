import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/repositories/supabase_group_repository.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/domain/enums/group_role.dart';
import 'package:meal_planner/domain/exceptions/group_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

// ─── Fake infrastructure ──────────────────────────────────────────────────────

typedef _Row = Map<String, dynamic>;

// Terminal fake for .single() → non-nullable map.
class _FakeMapChain extends Fake
    implements PostgrestTransformBuilder<PostgrestMap> {
  final PostgrestMap _value;
  final Object? _throwError;

  _FakeMapChain(PostgrestMap value, {Object? throwError})
      : _value = value,
        _throwError = throwError;

  Future<PostgrestMap> _future() => _throwError != null
      ? Future<PostgrestMap>.error(_throwError!)
      : Future.value(_value);

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
}

// Terminal fake for .maybeSingle() → nullable map.
class _FakeNullableMapChain extends Fake
    implements PostgrestTransformBuilder<PostgrestMap?> {
  final PostgrestMap? _value;
  final Object? _throwError;

  _FakeNullableMapChain(this._value, {Object? throwError})
      : _throwError = throwError;

  Future<PostgrestMap?> _future() => _throwError != null
      ? Future<PostgrestMap?>.error(_throwError!)
      : Future.value(_value);

  @override
  Future<R> then<R>(FutureOr<R> Function(PostgrestMap?) onValue,
          {Function? onError}) =>
      _future().then(onValue, onError: onError);

  @override
  Future<PostgrestMap?> catchError(Function f, {bool Function(Object)? test}) =>
      _future().catchError(f, test: test);

  @override
  Future<PostgrestMap?> whenComplete(FutureOr<void> Function() action) =>
      _future().whenComplete(action);

  @override
  Future<PostgrestMap?> timeout(Duration d,
          {FutureOr<PostgrestMap?> Function()? onTimeout}) =>
      _future().timeout(d, onTimeout: onTimeout);

  @override
  Stream<PostgrestMap?> asStream() => _future().asStream();
}

// List-resolving chain — supports .order(), .single(), .maybeSingle().
class _FakeListChain extends Fake
    implements PostgrestTransformBuilder<PostgrestList> {
  final PostgrestList _value;
  final Object? _throwError;

  _FakeListChain(List<PostgrestMap> value, {Object? throwError})
      : _value = value,
        _throwError = throwError;

  Future<PostgrestList> _future() => _throwError != null
      ? Future<PostgrestList>.error(_throwError!)
      : Future.value(_value);

  @override
  PostgrestTransformBuilder<PostgrestList> order(String column,
          {bool ascending = true,
          bool nullsFirst = false,
          String? referencedTable}) =>
      this;

  @override
  PostgrestTransformBuilder<PostgrestMap> single() =>
      _FakeMapChain(_value.isNotEmpty ? _value.first : {},
          throwError: _throwError);

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
}

// General filter chain — supports eq(), inFilter(), select(),
// single(), maybeSingle().
class _FakeChain<T> extends Fake implements PostgrestFilterBuilder<T> {
  final dynamic _response;
  final Object? _throwError;

  _FakeChain(this._response, {Object? throwError}) : _throwError = throwError;

  List<PostgrestMap> get _asList => _response is List
      ? (_response as List).cast<PostgrestMap>()
      : <PostgrestMap>[];

  Future<T> _future() => _throwError != null
      ? Future<T>.error(_throwError!)
      : Future<T>.value(_response as T);

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<T> inFilter(String column, List values) => this;

  @override
  PostgrestFilterBuilder<T> order(String column,
          {bool ascending = true,
          bool nullsFirst = false,
          String? referencedTable}) =>
      this;

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) =>
      _FakeListChain(_asList, throwError: _throwError);

  @override
  PostgrestTransformBuilder<PostgrestMap> single() =>
      _FakeMapChain(_asList.isNotEmpty ? _asList.first : {},
          throwError: _throwError);

  @override
  PostgrestTransformBuilder<PostgrestMap?> maybeSingle() =>
      _FakeNullableMapChain(_asList.isEmpty ? null : _asList.first,
          throwError: _throwError);

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
}

class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final dynamic _response;
  final Object? _throwError;

  _FakeQueryBuilder(this._response, {Object? throwError})
      : _throwError = throwError;

  List<PostgrestMap> get _asList => _response is List
      ? (_response as List).cast<PostgrestMap>()
      : <PostgrestMap>[];

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) =>
      _FakeChain<PostgrestList>(_asList, throwError: _throwError);

  @override
  PostgrestFilterBuilder<PostgrestList> insert(dynamic values,
          {bool defaultToNull = true}) =>
      _FakeChain<PostgrestList>(_asList, throwError: _throwError);

  @override
  PostgrestFilterBuilder<PostgrestList> update(Map<dynamic, dynamic> values,
          {bool defaultToNull = true}) =>
      _FakeChain<PostgrestList>(<PostgrestMap>[], throwError: _throwError);

  @override
  PostgrestFilterBuilder<PostgrestList> delete({bool defaultToNull = true}) =>
      _FakeChain<PostgrestList>(<PostgrestMap>[], throwError: _throwError);
}

class _FakeSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, List<dynamic>> _queues = {};
  final List<String> tableCalls = [];

  void enqueue(String table, dynamic response) {
    _queues.putIfAbsent(table, () => []).add(response);
  }

  void enqueueError(String table) {
    _queues.putIfAbsent(table, () => []).add(_ErrorSentinel());
  }

  void enqueuePostgrestError(String table) {
    _queues
        .putIfAbsent(table, () => [])
        .add(_ErrorSentinel(PostgrestException(message: 'db error')));
  }

  void enqueueSocketError(String table) {
    _queues
        .putIfAbsent(table, () => [])
        .add(_ErrorSentinel(SocketException('no connection')));
  }

  @override
  SupabaseQueryBuilder from(String table) {
    tableCalls.add(table);
    final queue = _queues[table] ?? [];
    final entry = queue.isNotEmpty ? queue.removeAt(0) : <PostgrestMap>[];
    if (entry is _ErrorSentinel) {
      return _FakeQueryBuilder(null,
          throwError: entry.error ?? Exception('supabase error'));
    }
    return _FakeQueryBuilder(entry);
  }
}

class _ErrorSentinel {
  final Object? error;
  _ErrorSentinel([this.error]);
}

// ─── Test helpers ─────────────────────────────────────────────────────────────

const _groupId = 'group-1';
const _userId = 'user-1';
const _groups = 'groups';
const _members = 'group_members';

_Row _groupRow({
  String id = _groupId,
  String name = 'Test Group',
  String imageUrl = 'https://img.test/g.png',
}) =>
    {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'week_start_day': null,
      'default_meal_slots': null,
      'rotation_weight': null,
      'carb_variety_weight': null,
    };

_Row _memberRow({
  String groupId = _groupId,
  String userId = _userId,
  String userName = 'Alice',
  String? userImage,
}) =>
    {
      'group_id': groupId,
      'user_id': userId,
      'users': {
        'id': userId,
        'name': userName,
        'image_url': userImage,
      },
    };

SupabaseGroupRepository _makeRepo(_FakeSupabaseClient client) =>
    SupabaseGroupRepository(supabase: client);

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late _FakeSupabaseClient client;
  late SupabaseGroupRepository repo;

  setUp(() {
    client = _FakeSupabaseClient();
    repo = _makeRepo(client);
  });

  // ── createGroup ─────────────────────────────────────────────────────────────

  group('createGroup', () {
    test('completes on success', () async {
      client
        ..enqueue(_groups, null)
        ..enqueue(_members, null);
      await expectLater(
          repo.createGroup(_groupId, 'My Group', 'url', _userId), completes);
    });

    test('throws GroupCreationException on groups table error', () async {
      client.enqueueError(_groups);
      await expectLater(repo.createGroup(_groupId, 'My Group', 'url', _userId),
          throwsA(isA<GroupCreationException>()));
    });

    test('throws GroupCreationException on group_members table error',
        () async {
      client
        ..enqueue(_groups, null)
        ..enqueueError(_members);
      await expectLater(repo.createGroup(_groupId, 'My Group', 'url', _userId),
          throwsA(isA<GroupCreationException>()));
    });

    test('throws GroupCreationException (PostgrestException → Datenbankfehler)',
        () async {
      client.enqueuePostgrestError(_groups);
      await expectLater(
        repo.createGroup(_groupId, 'My Group', 'url', _userId),
        throwsA(isA<GroupCreationException>()
            .having((e) => e.message, 'message', contains('Datenbankfehler'))),
      );
    });

    test(
        'throws GroupCreationException (SocketException → Keine Internetverbindung)',
        () async {
      client.enqueueSocketError(_groups);
      await expectLater(
        repo.createGroup(_groupId, 'My Group', 'url', _userId),
        throwsA(isA<GroupCreationException>().having(
            (e) => e.message, 'message', 'Keine Internetverbindung')),
      );
    });
  });

  // ── updateGroup ─────────────────────────────────────────────────────────────

  group('updateGroup', () {
    test('completes on success', () async {
      client.enqueue(_groups, null);
      await expectLater(
          repo.updateGroup(
              oldGroupId: _groupId, newName: 'New Name', imageUrl: 'url'),
          completes);
    });

    test('throws GroupCreationException on error', () async {
      client.enqueueError(_groups);
      await expectLater(
          repo.updateGroup(
              oldGroupId: _groupId, newName: 'New Name', imageUrl: 'url'),
          throwsA(isA<GroupCreationException>()));
    });

    test('throws GroupCreationException (PostgrestException → Datenbankfehler)',
        () async {
      client.enqueuePostgrestError(_groups);
      await expectLater(
        repo.updateGroup(
            oldGroupId: _groupId, newName: 'New Name', imageUrl: 'url'),
        throwsA(isA<GroupCreationException>()
            .having((e) => e.message, 'message', contains('Datenbankfehler'))),
      );
    });

    test(
        'throws GroupCreationException (SocketException → Keine Internetverbindung)',
        () async {
      client.enqueueSocketError(_groups);
      await expectLater(
        repo.updateGroup(
            oldGroupId: _groupId, newName: 'New Name', imageUrl: 'url'),
        throwsA(isA<GroupCreationException>().having(
            (e) => e.message, 'message', 'Keine Internetverbindung')),
      );
    });
  });

  // ── getGroup ────────────────────────────────────────────────────────────────

  group('getGroup', () {
    test('returns Group with correct fields', () async {
      client.enqueue(_groups, [_groupRow(id: 'g-1', name: 'My Group')]);
      final group = await repo.getGroup('g-1');
      expect(group, isA<Group>());
      expect(group!.id, 'g-1');
      expect(group.name, 'My Group');
    });

    test('returns null when group not found', () async {
      client.enqueue(_groups, <_Row>[]);
      final group = await repo.getGroup('nonexistent');
      expect(group, isNull);
    });

    test('maps imageUrl correctly', () async {
      client.enqueue(_groups,
          [_groupRow(id: 'g-1', imageUrl: 'https://img.test/pic.jpg')]);
      final group = await repo.getGroup('g-1');
      expect(group!.imageUrl, 'https://img.test/pic.jpg');
    });

    test('throws GroupNotFoundException on error', () async {
      client.enqueueError(_groups);
      await expectLater(
          repo.getGroup('g-1'), throwsA(isA<GroupNotFoundException>()));
    });

    test('throws GroupNotFoundException (PostgrestException → Datenbankfehler)',
        () async {
      client.enqueuePostgrestError(_groups);
      await expectLater(repo.getGroup('g-1'),
          throwsA(isA<GroupNotFoundException>()));
    });

    test(
        'throws GroupNotFoundException (SocketException → Keine Internetverbindung)',
        () async {
      client.enqueueSocketError(_groups);
      await expectLater(repo.getGroup('g-1'),
          throwsA(isA<GroupNotFoundException>()));
    });
  });

  // ── getGroupMembers ─────────────────────────────────────────────────────────

  group('getGroupMembers', () {
    test('returns mapped User list', () async {
      client.enqueue(_members, [
        _memberRow(userId: 'u-1', userName: 'Alice'),
        _memberRow(userId: 'u-2', userName: 'Bob')
      ]);
      final members = await repo.getGroupMembers(_groupId);
      expect(members, hasLength(2));
      expect(members.first, isA<User>());
      expect(members.first.name, 'Alice');
      expect(members[1].name, 'Bob');
    });

    test('returns empty list when no members', () async {
      client.enqueue(_members, <_Row>[]);
      final members = await repo.getGroupMembers(_groupId);
      expect(members, isEmpty);
    });

    test('maps user id correctly', () async {
      client
          .enqueue(_members, [_memberRow(userId: 'u-42', userName: 'Charlie')]);
      final members = await repo.getGroupMembers(_groupId);
      expect(members.first.id, 'u-42');
    });

    test('throws GroupMemberException on error', () async {
      client.enqueueError(_members);
      await expectLater(
          repo.getGroupMembers(_groupId), throwsA(isA<GroupMemberException>()));
    });

    test('throws GroupMemberException (PostgrestException → Datenbankfehler)',
        () async {
      client.enqueuePostgrestError(_members);
      await expectLater(repo.getGroupMembers(_groupId),
          throwsA(isA<GroupMemberException>()));
    });

    test(
        'throws GroupMemberException (SocketException → Keine Internetverbindung)',
        () async {
      client.enqueueSocketError(_members);
      await expectLater(repo.getGroupMembers(_groupId),
          throwsA(isA<GroupMemberException>()));
    });
  });

  // ── getGroupsByIds ──────────────────────────────────────────────────────────

  group('getGroupsByIds', () {
    test('returns empty list immediately for empty input — no Supabase call',
        () async {
      final result = await repo.getGroupsByIds([]);
      expect(result, isEmpty);
      expect(client.tableCalls, isEmpty);
    });

    test('returns mapped Group list', () async {
      client.enqueue(_groups, [
        _groupRow(id: 'g-1', name: 'Group A'),
        _groupRow(id: 'g-2', name: 'Group B'),
      ]);
      final groups = await repo.getGroupsByIds(['g-1', 'g-2']);
      expect(groups, hasLength(2));
      expect(groups.first.id, 'g-1');
      expect(groups[1].id, 'g-2');
    });

    test('throws GroupNotFoundException on error', () async {
      client.enqueueError(_groups);
      await expectLater(
          repo.getGroupsByIds(['g-1']), throwsA(isA<GroupNotFoundException>()));
    });

    test('throws GroupNotFoundException (PostgrestException → Datenbankfehler)',
        () async {
      client.enqueuePostgrestError(_groups);
      await expectLater(repo.getGroupsByIds(['g-1']),
          throwsA(isA<GroupNotFoundException>()));
    });

    test(
        'throws GroupNotFoundException (SocketException → Keine Internetverbindung)',
        () async {
      client.enqueueSocketError(_groups);
      await expectLater(repo.getGroupsByIds(['g-1']),
          throwsA(isA<GroupNotFoundException>()));
    });
  });

  // ── updateGroupPic ──────────────────────────────────────────────────────────

  group('updateGroupPic', () {
    test('completes on success', () async {
      client.enqueue(_groups, null);
      await expectLater(
          repo.updateGroupPic(_groupId, 'https://img.test/new.jpg'), completes);
    });

    test('throws GroupUpdateException on error', () async {
      client.enqueueError(_groups);
      await expectLater(
          repo.updateGroupPic(_groupId, 'https://img.test/new.jpg'),
          throwsA(isA<GroupUpdateException>()));
    });

    test('throws GroupUpdateException (PostgrestException → Datenbankfehler)',
        () async {
      client.enqueuePostgrestError(_groups);
      await expectLater(repo.updateGroupPic(_groupId, 'url'),
          throwsA(isA<GroupUpdateException>()));
    });

    test(
        'throws GroupUpdateException (SocketException → Keine Internetverbindung)',
        () async {
      client.enqueueSocketError(_groups);
      await expectLater(repo.updateGroupPic(_groupId, 'url'),
          throwsA(isA<GroupUpdateException>()));
    });
  });

  // ── deleteGroup ─────────────────────────────────────────────────────────────

  group('deleteGroup', () {
    test('completes on success', () async {
      client
        ..enqueue(_members, null)
        ..enqueue(_groups, null);
      await expectLater(repo.deleteGroup(_groupId), completes);
    });

    test('deletes members before group (FK constraint order)', () async {
      client
        ..enqueue(_members, null)
        ..enqueue(_groups, null);
      await repo.deleteGroup(_groupId);
      expect(client.tableCalls, [_members, _groups]);
    });

    test('throws GroupDeletionException on error', () async {
      client.enqueueError(_members);
      await expectLater(
          repo.deleteGroup(_groupId), throwsA(isA<GroupDeletionException>()));
    });

    test('throws GroupDeletionException (PostgrestException → Datenbankfehler)',
        () async {
      client.enqueuePostgrestError(_members);
      await expectLater(repo.deleteGroup(_groupId),
          throwsA(isA<GroupDeletionException>()));
    });

    test(
        'throws GroupDeletionException (SocketException → Keine Internetverbindung)',
        () async {
      client.enqueueSocketError(_members);
      await expectLater(repo.deleteGroup(_groupId),
          throwsA(isA<GroupDeletionException>()));
    });
  });

  // ── addMember ───────────────────────────────────────────────────────────────

  group('addMember', () {
    test('completes on success', () async {
      client.enqueue(_members, null);
      await expectLater(repo.addMember(_groupId, _userId), completes);
    });

    test('throws GroupMemberException on error', () async {
      client.enqueueError(_members);
      await expectLater(repo.addMember(_groupId, _userId),
          throwsA(isA<GroupMemberException>()));
    });

    test('throws GroupMemberException (PostgrestException → Datenbankfehler)',
        () async {
      client.enqueuePostgrestError(_members);
      await expectLater(repo.addMember(_groupId, _userId),
          throwsA(isA<GroupMemberException>()));
    });

    test(
        'throws GroupMemberException (SocketException → Keine Internetverbindung)',
        () async {
      client.enqueueSocketError(_members);
      await expectLater(repo.addMember(_groupId, _userId),
          throwsA(isA<GroupMemberException>()));
    });
  });

  // ── removeMember ────────────────────────────────────────────────────────────

  group('removeMember', () {
    test('completes on success', () async {
      client.enqueue(_members, null);
      await expectLater(repo.removeMember(_groupId, _userId), completes);
    });

    test('throws GroupMemberException on error', () async {
      client.enqueueError(_members);
      await expectLater(repo.removeMember(_groupId, _userId),
          throwsA(isA<GroupMemberException>()));
    });

    test('throws GroupMemberException (PostgrestException → Datenbankfehler)',
        () async {
      client.enqueuePostgrestError(_members);
      await expectLater(repo.removeMember(_groupId, _userId),
          throwsA(isA<GroupMemberException>()));
    });

    test(
        'throws GroupMemberException (SocketException → Keine Internetverbindung)',
        () async {
      client.enqueueSocketError(_members);
      await expectLater(repo.removeMember(_groupId, _userId),
          throwsA(isA<GroupMemberException>()));
    });
  });

  // ── getMemberIds ────────────────────────────────────────────────────────────

  group('getMemberIds', () {
    test('returns list of member user ids', () async {
      client.enqueue(_members, [
        {'user_id': 'u-1'},
        {'user_id': 'u-2'},
        {'user_id': 'u-3'}
      ]);
      final ids = await repo.getMemberIds(_groupId);
      expect(ids, ['u-1', 'u-2', 'u-3']);
    });

    test('returns empty list when no members', () async {
      client.enqueue(_members, <_Row>[]);
      final ids = await repo.getMemberIds(_groupId);
      expect(ids, isEmpty);
    });

    test('throws GroupMemberException on error', () async {
      client.enqueueError(_members);
      await expectLater(
          repo.getMemberIds(_groupId), throwsA(isA<GroupMemberException>()));
    });

    test('throws GroupMemberException (PostgrestException → Datenbankfehler)',
        () async {
      client.enqueuePostgrestError(_members);
      await expectLater(repo.getMemberIds(_groupId),
          throwsA(isA<GroupMemberException>()));
    });

    test(
        'throws GroupMemberException (SocketException → Keine Internetverbindung)',
        () async {
      client.enqueueSocketError(_members);
      await expectLater(repo.getMemberIds(_groupId),
          throwsA(isA<GroupMemberException>()));
    });
  });

  // ── updateSettings ──────────────────────────────────────────────────────────

  group('updateSettings', () {
    test('completes on success', () async {
      client.enqueue(_groups, null);
      await expectLater(
          repo.updateSettings(_groupId, const GroupSettings()), completes);
    });

    test('throws GroupUpdateException on error', () async {
      client.enqueueError(_groups);
      await expectLater(repo.updateSettings(_groupId, const GroupSettings()),
          throwsA(isA<GroupUpdateException>()));
    });

    test('throws GroupUpdateException (PostgrestException → Datenbankfehler)',
        () async {
      client.enqueuePostgrestError(_groups);
      await expectLater(repo.updateSettings(_groupId, const GroupSettings()),
          throwsA(isA<GroupUpdateException>()));
    });

    test(
        'throws GroupUpdateException (SocketException → Keine Internetverbindung)',
        () async {
      client.enqueueSocketError(_groups);
      await expectLater(repo.updateSettings(_groupId, const GroupSettings()),
          throwsA(isA<GroupUpdateException>()));
    });
  });

  // ── getUserGroups ───────────────────────────────────────────────────────────

  group('getUserGroups', () {
    test('returns empty list when user has no memberships', () async {
      client.enqueue(_members, <_Row>[]);
      final groups = await repo.getUserGroups(_userId);
      expect(groups, isEmpty);
    });

    test('returns Group list by resolving each membership', () async {
      client
        ..enqueue(_members, [
          {'group_id': 'g-1'},
          {'group_id': 'g-2'},
        ])
        ..enqueue(_groups, [_groupRow(id: 'g-1', name: 'Group A')])
        ..enqueue(_groups, [_groupRow(id: 'g-2', name: 'Group B')]);
      final groups = await repo.getUserGroups(_userId);
      expect(groups, hasLength(2));
      expect(groups.map((g) => g.id), containsAll(['g-1', 'g-2']));
    });

    test('throws GroupsNotFoundException on error', () async {
      client.enqueueError(_members);
      await expectLater(
          repo.getUserGroups(_userId), throwsA(isA<GroupsNotFoundException>()));
    });

    test('skips groups where getGroup returns null', () async {
      client
        ..enqueue(_members, [
          {'group_id': 'g-1'},
          {'group_id': 'g-deleted'},
        ])
        ..enqueue(_groups, [_groupRow(id: 'g-1', name: 'Existing')])
        ..enqueue(_groups, <_Row>[]); // g-deleted not found → null
      final groups = await repo.getUserGroups(_userId);
      expect(groups, hasLength(1));
      expect(groups.first.id, 'g-1');
    });

    test('throws GroupsNotFoundException when getGroup fails mid-iteration',
        () async {
      client
        ..enqueue(_members, [
          {'group_id': 'g-1'},
          {'group_id': 'g-broken'},
        ])
        ..enqueue(_groups, [_groupRow(id: 'g-1', name: 'OK')])
        ..enqueueError(_groups); // g-broken → getGroup throws
      await expectLater(
          repo.getUserGroups(_userId), throwsA(isA<GroupsNotFoundException>()));
    });
  });

  // ── updateMemberRole ────────────────────────────────────────────────────────

  group('updateMemberRole', () {
    test('completes on success', () async {
      client.enqueue(_members, null);
      await expectLater(
          repo.updateMemberRole(_groupId, _userId, 'admin'), completes);
    });

    test('throws GroupMemberException on error', () async {
      client.enqueueError(_members);
      await expectLater(repo.updateMemberRole(_groupId, _userId, 'admin'),
          throwsA(isA<GroupMemberException>()));
    });

    test('throws GroupMemberException (PostgrestException → Datenbankfehler)',
        () async {
      client.enqueuePostgrestError(_members);
      await expectLater(repo.updateMemberRole(_groupId, _userId, 'admin'),
          throwsA(isA<GroupMemberException>()));
    });

    test(
        'throws GroupMemberException (SocketException → Keine Internetverbindung)',
        () async {
      client.enqueueSocketError(_members);
      await expectLater(repo.updateMemberRole(_groupId, _userId, 'admin'),
          throwsA(isA<GroupMemberException>()));
    });
  });

  // ── getMemberRole ───────────────────────────────────────────────────────────

  group('getMemberRole', () {
    test('returns GroupRole.admin for admin role', () async {
      client.enqueue(_members, [
        {'role': 'admin'}
      ]);
      final role = await repo.getMemberRole(_groupId, _userId);
      expect(role, GroupRole.admin);
    });

    test('returns GroupRole.member for member role', () async {
      client.enqueue(_members, [
        {'role': 'member'}
      ]);
      final role = await repo.getMemberRole(_groupId, _userId);
      expect(role, GroupRole.member);
    });

    test('returns null when member not found', () async {
      client.enqueue(_members, <_Row>[]);
      final role = await repo.getMemberRole(_groupId, _userId);
      expect(role, isNull);
    });

    test('returns null on error (swallows exceptions)', () async {
      client.enqueueError(_members);
      final role = await repo.getMemberRole(_groupId, _userId);
      expect(role, isNull);
    });
  });
}
