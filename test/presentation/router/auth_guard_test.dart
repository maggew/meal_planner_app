import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/entities/user.dart' as domain;
import 'package:meal_planner/domain/repositories/auth_repository.dart';
import 'package:meal_planner/domain/repositories/group_repository.dart';
import 'package:meal_planner/domain/repositories/user_repository.dart';
import 'package:meal_planner/presentation/router/auth_guard.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockGroupRepository extends Mock implements GroupRepository {}

class MockNavigationResolver extends Mock implements NavigationResolver {}

class MockStackRouter extends Mock implements StackRouter {}

// ── Test SessionNotifier ───────────────────────────────────────────────────
//
// Overrides `build` to avoid LocalStorageService in constructors,
// and `loadSession` to skip the real async chain and just set state.

class _TestSessionNotifier extends SessionNotifier {
  _TestSessionNotifier(this._initial, {SessionState? afterLoad})
      : _afterLoad = afterLoad;

  final SessionState _initial;
  final SessionState? _afterLoad;

  @override
  SessionState build() => _initial;

  @override
  Future<void> loadSession(String userId) async {
    state = _afterLoad ?? _initial;
  }
}

// ── Secure Storage Mock ────────────────────────────────────────────────────

const _secureStorageChannel =
    MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

final _secureStore = <String, String>{};

void _setupSecureStorage([Map<String, String> initial = const {}]) {
  _secureStore
    ..clear()
    ..addAll(initial);

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_secureStorageChannel, (call) async {
    final args = call.arguments as Map;
    switch (call.method) {
      case 'read':
        return _secureStore[args['key'] as String];
      case 'write':
        final key = args['key'] as String;
        final value = args['value'] as String?;
        if (value != null) {
          _secureStore[key] = value;
        } else {
          _secureStore.remove(key);
        }
        return null;
      default:
        return null;
    }
  });
}

// ── Constants ──────────────────────────────────────────────────────────────

const _firebaseUid = 'fb-uid-123';
const _supabaseUserId = 'sb-user-456';
final _fakeUser = domain.User(id: _supabaseUserId, name: 'Alice');
final _fakeGroup = Group(id: 'g1', name: 'Test', imageUrl: '');

// ── Helper: guard via provider so `Ref` belongs to the container ───────────

final _authGuardProvider = Provider((ref) => AuthGuard(ref));

ProviderContainer _makeContainer({
  required MockAuthRepository authRepo,
  required SessionState initialSession,
  SessionState? sessionAfterLoad,
  MockUserRepository? userRepo,
  MockGroupRepository? groupRepo,
}) {
  return ProviderContainer(overrides: [
    authRepositoryProvider.overrideWithValue(authRepo),
    sessionProvider.overrideWith(
        () => _TestSessionNotifier(initialSession, afterLoad: sessionAfterLoad)),
    if (userRepo != null) userRepositoryProvider.overrideWithValue(userRepo),
    if (groupRepo != null) groupRepositoryProvider.overrideWithValue(groupRepo),
  ]);
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late MockAuthRepository authRepo;
  late MockNavigationResolver resolver;
  late MockStackRouter mockRouter;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(LoginRoute());
    registerFallbackValue(GroupOnboardingRoute());
    registerFallbackValue(GroupsRoute());
  });

  setUp(() {
    authRepo = MockAuthRepository();
    resolver = MockNavigationResolver();
    mockRouter = MockStackRouter();
    SharedPreferences.setMockInitialValues({});
    _setupSecureStorage();
  });

  // ── Firebase UID fehlt ─────────────────────────────────────────────────

  group('Firebase UID fehlt', () {
    test('null → replace(LoginRoute)', () async {
      when(() => authRepo.getCurrentUserId()).thenReturn(null);
      final container = _makeContainer(
        authRepo: authRepo,
        initialSession: const SessionState(),
      );
      addTearDown(container.dispose);

      final done = Completer<void>();
      when(() => mockRouter.replace(any()))
          .thenAnswer((_) async { done.complete(); return null; });

      container.read(_authGuardProvider).onNavigation(resolver, mockRouter);

      await done.future.timeout(const Duration(seconds: 1));
      verify(() => mockRouter.replace(any(that: isA<LoginRoute>()))).called(1);
      verifyNever(() => resolver.next(any()));
    });

    test('leer → replace(LoginRoute)', () async {
      when(() => authRepo.getCurrentUserId()).thenReturn('');
      final container = _makeContainer(
        authRepo: authRepo,
        initialSession: const SessionState(),
      );
      addTearDown(container.dispose);

      final done = Completer<void>();
      when(() => mockRouter.replace(any()))
          .thenAnswer((_) async { done.complete(); return null; });

      container.read(_authGuardProvider).onNavigation(resolver, mockRouter);

      await done.future.timeout(const Duration(seconds: 1));
      verify(() => mockRouter.replace(any(that: isA<LoginRoute>()))).called(1);
      verifyNever(() => resolver.next(any()));
    });
  });

  // ── Fast path ──────────────────────────────────────────────────────────

  group('Fast path', () {
    test(
        'Session hat userId + group → resolver.next(true), kein userRepo-Aufruf',
        () async {
      when(() => authRepo.getCurrentUserId()).thenReturn(_firebaseUid);
      final userRepo = MockUserRepository();
      final container = _makeContainer(
        authRepo: authRepo,
        initialSession: SessionState(userId: _supabaseUserId, group: _fakeGroup),
        userRepo: userRepo,
      );
      addTearDown(container.dispose);

      final done = Completer<void>();
      when(() => resolver.next(any())).thenAnswer((_) { done.complete(); });

      container.read(_authGuardProvider).onNavigation(resolver, mockRouter);

      await done.future.timeout(const Duration(seconds: 1));
      verify(() => resolver.next(true)).called(1);
      verifyNever(() => userRepo.getUserByFirebaseUid(any()));
      verifyNever(() => mockRouter.replace(any()));
    });
  });

  // ── Session nicht geladen, User online gefunden ────────────────────────

  group('Session nicht geladen – User online gefunden', () {
    test('userRepo liefert User → loadSession → resolver.next(true)', () async {
      when(() => authRepo.getCurrentUserId()).thenReturn(_firebaseUid);
      final userRepo = MockUserRepository();
      when(() => userRepo.getUserByFirebaseUid(_firebaseUid))
          .thenAnswer((_) async => _fakeUser);

      final container = _makeContainer(
        authRepo: authRepo,
        initialSession: const SessionState(),
        sessionAfterLoad:
            SessionState(userId: _supabaseUserId, groupId: 'g1', group: _fakeGroup),
        userRepo: userRepo,
      );
      addTearDown(container.dispose);

      final done = Completer<void>();
      when(() => resolver.next(any())).thenAnswer((_) { done.complete(); });

      container.read(_authGuardProvider).onNavigation(resolver, mockRouter);

      await done.future.timeout(const Duration(seconds: 1));
      verify(() => resolver.next(true)).called(1);
      verifyNever(() => mockRouter.replace(any()));
    });
  });

  // ── Session nicht geladen, Netzwerkfehler ─────────────────────────────

  group('Session nicht geladen – Netzwerkfehler', () {
    test('Network wirft, gecachte ID vorhanden → loadSession → resolver.next(true)',
        () async {
      when(() => authRepo.getCurrentUserId()).thenReturn(_firebaseUid);
      final userRepo = MockUserRepository();
      when(() => userRepo.getUserByFirebaseUid(any()))
          .thenThrow(Exception('network error'));
      _setupSecureStorage({'supabase_user_id': _supabaseUserId});

      final container = _makeContainer(
        authRepo: authRepo,
        initialSession: const SessionState(),
        sessionAfterLoad:
            SessionState(userId: _supabaseUserId, groupId: 'g1', group: _fakeGroup),
        userRepo: userRepo,
      );
      addTearDown(container.dispose);

      final done = Completer<void>();
      when(() => resolver.next(any())).thenAnswer((_) { done.complete(); });

      container.read(_authGuardProvider).onNavigation(resolver, mockRouter);

      await done.future.timeout(const Duration(seconds: 1));
      verify(() => resolver.next(true)).called(1);
    });

    test('Network wirft, kein Cache → replace(LoginRoute)', () async {
      when(() => authRepo.getCurrentUserId()).thenReturn(_firebaseUid);
      final userRepo = MockUserRepository();
      when(() => userRepo.getUserByFirebaseUid(any()))
          .thenThrow(Exception('network error'));
      // Kein cached supabase user ID → _setupSecureStorage() ohne Argumente

      final container = _makeContainer(
        authRepo: authRepo,
        initialSession: const SessionState(),
        userRepo: userRepo,
      );
      addTearDown(container.dispose);

      final done = Completer<void>();
      when(() => mockRouter.replace(any()))
          .thenAnswer((_) async { done.complete(); return null; });

      container.read(_authGuardProvider).onNavigation(resolver, mockRouter);

      await done.future.timeout(const Duration(seconds: 1));
      verify(() => mockRouter.replace(any(that: isA<LoginRoute>()))).called(1);
      verifyNever(() => resolver.next(any()));
    });
  });

  // ── Session geladen, keine Gruppe ──────────────────────────────────────

  group('Session geladen, keine Gruppe', () {
    void setupNoGroup(MockUserRepository userRepo) {
      when(() => authRepo.getCurrentUserId()).thenReturn(_firebaseUid);
      when(() => userRepo.getUserByFirebaseUid(_firebaseUid))
          .thenAnswer((_) async => _fakeUser);
    }

    test('getUserGroups liefert Gruppen → replace(GroupsRoute)', () async {
      final userRepo = MockUserRepository();
      final groupRepo = MockGroupRepository();
      setupNoGroup(userRepo);
      when(() => groupRepo.getUserGroups(_supabaseUserId))
          .thenAnswer((_) async => [_fakeGroup]);

      final container = _makeContainer(
        authRepo: authRepo,
        initialSession: const SessionState(),
        sessionAfterLoad: SessionState(userId: _supabaseUserId, groupId: null),
        userRepo: userRepo,
        groupRepo: groupRepo,
      );
      addTearDown(container.dispose);

      final done = Completer<void>();
      when(() => mockRouter.replace(any()))
          .thenAnswer((_) async { done.complete(); return null; });

      container.read(_authGuardProvider).onNavigation(resolver, mockRouter);

      await done.future.timeout(const Duration(seconds: 1));
      verify(() => mockRouter.replace(any(that: isA<GroupsRoute>()))).called(1);
      verifyNever(() => resolver.next(any()));
    });

    test('getUserGroups leer → replace(GroupOnboardingRoute)', () async {
      final userRepo = MockUserRepository();
      final groupRepo = MockGroupRepository();
      setupNoGroup(userRepo);
      when(() => groupRepo.getUserGroups(_supabaseUserId))
          .thenAnswer((_) async => []);

      final container = _makeContainer(
        authRepo: authRepo,
        initialSession: const SessionState(),
        sessionAfterLoad: SessionState(userId: _supabaseUserId, groupId: null),
        userRepo: userRepo,
        groupRepo: groupRepo,
      );
      addTearDown(container.dispose);

      final done = Completer<void>();
      when(() => mockRouter.replace(any()))
          .thenAnswer((_) async { done.complete(); return null; });

      container.read(_authGuardProvider).onNavigation(resolver, mockRouter);

      await done.future.timeout(const Duration(seconds: 1));
      verify(() => mockRouter.replace(any(that: isA<GroupOnboardingRoute>()))).called(1);
    });

    test('getUserGroups wirft → replace(GroupOnboardingRoute)', () async {
      final userRepo = MockUserRepository();
      final groupRepo = MockGroupRepository();
      setupNoGroup(userRepo);
      when(() => groupRepo.getUserGroups(any())).thenThrow(Exception('offline'));

      final container = _makeContainer(
        authRepo: authRepo,
        initialSession: const SessionState(),
        sessionAfterLoad: SessionState(userId: _supabaseUserId, groupId: null),
        userRepo: userRepo,
        groupRepo: groupRepo,
      );
      addTearDown(container.dispose);

      final done = Completer<void>();
      when(() => mockRouter.replace(any()))
          .thenAnswer((_) async { done.complete(); return null; });

      container.read(_authGuardProvider).onNavigation(resolver, mockRouter);

      await done.future.timeout(const Duration(seconds: 1));
      verify(() => mockRouter.replace(any(that: isA<GroupOnboardingRoute>()))).called(1);
    });
  });
}
