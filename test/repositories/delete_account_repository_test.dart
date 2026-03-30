import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/data/repositories/delete_account_repository_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

// ── Mocks ──────────────────────────────────────────────────────────────────

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements User {}

class MockUserInfo extends Mock implements UserInfo {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class FakeAuthCredential extends Fake implements AuthCredential {}

// ── Drift Fakes ────────────────────────────────────────────────────────────

class _FakeGenDb extends Fake implements GeneratedDatabase {}

class _FakeDeleteStatement<T extends Table, D> extends Fake
    implements DeleteStatement<T, D> {
  @override
  Future<int> go() async => 0;
}

class FakeAppDatabase extends Fake implements AppDatabase {
  @override
  $LocalShoppingItemsTable get localShoppingItems =>
      $LocalShoppingItemsTable(_FakeGenDb());
  @override
  $LocalRecipesTable get localRecipes => $LocalRecipesTable(_FakeGenDb());
  @override
  $LocalMealPlanEntriesTable get localMealPlanEntries =>
      $LocalMealPlanEntriesTable(_FakeGenDb());

  @override
  DeleteStatement<T, D> delete<T extends Table, D>(TableInfo<T, D> table) =>
      _FakeDeleteStatement<T, D>();
}

// ── Supabase Fake ──────────────────────────────────────────────────────────

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final MockFunctionsClient mockFunctions;
  FakeSupabaseClient(this.mockFunctions);

  @override
  FunctionsClient get functions => mockFunctions;
}

// ── Helpers ────────────────────────────────────────────────────────────────

const _password = 'secret123';
const _email = 'alice@test.com';

MockFirebaseUser _makePasswordUser() {
  final user = MockFirebaseUser();
  final info = MockUserInfo();
  when(() => info.providerId).thenReturn('password');
  when(() => user.providerData).thenReturn([info]);
  when(() => user.email).thenReturn(_email);
  return user;
}

MockFirebaseUser _makeGoogleOnlyUser() {
  final user = MockFirebaseUser();
  final info = MockUserInfo();
  when(() => info.providerId).thenReturn('google.com');
  when(() => user.providerData).thenReturn([info]);
  return user;
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late MockFirebaseAuth auth;
  late MockFunctionsClient functions;
  late MockGoogleSignIn googleSignIn;
  late FakeAppDatabase db;
  late FakeSupabaseClient supabase;
  late DeleteAccountRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    auth = MockFirebaseAuth();
    functions = MockFunctionsClient();
    googleSignIn = MockGoogleSignIn();
    db = FakeAppDatabase();
    supabase = FakeSupabaseClient(functions);
    repo = DeleteAccountRepositoryImpl(
      db: db,
      auth: auth,
      googleSignIn: googleSignIn,
      supabase: supabase,
    );
  });

  // ── requiresPasswordReauth ─────────────────────────────────────────────

  group('requiresPasswordReauth', () {
    test('true wenn Provider "password" enthält', () {
      final user = _makePasswordUser();
      when(() => auth.currentUser).thenReturn(user);
      expect(repo.requiresPasswordReauth, isTrue);
    });

    test('false wenn nur "google.com" Provider', () {
      final user = _makeGoogleOnlyUser();
      when(() => auth.currentUser).thenReturn(user);
      expect(repo.requiresPasswordReauth, isFalse);
    });

    test('true wenn kein User (currentUser == null)', () {
      when(() => auth.currentUser).thenReturn(null);
      expect(repo.requiresPasswordReauth, isTrue);
    });

    test('false wenn leere providerData', () {
      final user = MockFirebaseUser();
      when(() => user.providerData).thenReturn([]);
      when(() => auth.currentUser).thenReturn(user);
      expect(repo.requiresPasswordReauth, isFalse);
    });
  });

  // ── deleteAccount (Passwort-Provider) ──────────────────────────────────

  group('deleteAccount – Passwort-Reauth', () {
    test('kompletter Flow: reauth → supabase → firebase delete → db clear',
        () async {
      final user = _makePasswordUser();
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.reauthenticateWithCredential(any()))
          .thenAnswer((_) async => MockUserCredential());
      when(() => functions.invoke(any())).thenAnswer(
          (_) async => FunctionResponse(status: 200, data: null));
      when(() => user.delete()).thenAnswer((_) async {});

      await repo.deleteAccount(password: _password);

      verifyInOrder([
        () => user.reauthenticateWithCredential(any()),
        () => functions.invoke('delete-account'),
        () => user.delete(),
      ]);
    });

    test('user == null → wirft Exception', () {
      when(() => auth.currentUser).thenReturn(null);

      expect(
        () => repo.deleteAccount(password: _password),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', contains('Not logged in'))),
      );
    });

    test('reauth fehlschlägt → deleteAccount wirft', () {
      final user = _makePasswordUser();
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.reauthenticateWithCredential(any()))
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));

      expect(
        () => repo.deleteAccount(password: _password),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  // ── deleteAccount (Google-Provider) ───────────────────────────────────

  group('deleteAccount – Google-Reauth', () {
    test('kompletter Flow: Google reauth → supabase → firebase delete → db clear',
        () async {
      final user = _makeGoogleOnlyUser();
      when(() => auth.currentUser).thenReturn(user);

      // Google Sign-In flow
      final mockGoogleAuth = MockGoogleSignInAuthentication();
      when(() => mockGoogleAuth.idToken).thenReturn('fake-id-token');
      final mockAccount = MockGoogleSignInAccount();
      when(() => mockAccount.authentication).thenReturn(mockGoogleAuth);
      when(() => googleSignIn.initialize(serverClientId: any(named: 'serverClientId')))
          .thenAnswer((_) async {});
      when(() => googleSignIn.authenticate())
          .thenAnswer((_) async => mockAccount);

      // Rest of delete flow
      when(() => user.reauthenticateWithCredential(any()))
          .thenAnswer((_) async => MockUserCredential());
      when(() => functions.invoke(any()))
          .thenAnswer((_) async => FunctionResponse(status: 200, data: null));
      when(() => user.delete()).thenAnswer((_) async {});

      await repo.deleteAccount();

      verifyInOrder([
        () => googleSignIn.initialize(serverClientId: any(named: 'serverClientId')),
        () => googleSignIn.authenticate(),
        () => user.reauthenticateWithCredential(any()),
        () => functions.invoke('delete-account'),
        () => user.delete(),
      ]);
    });

    test('Google authenticate fehlschlägt → deleteAccount wirft', () {
      final user = _makeGoogleOnlyUser();
      when(() => auth.currentUser).thenReturn(user);
      when(() => googleSignIn.initialize(serverClientId: any(named: 'serverClientId')))
          .thenAnswer((_) async {});
      when(() => googleSignIn.authenticate())
          .thenThrow(Exception('Google sign-in cancelled'));

      expect(
        () => repo.deleteAccount(),
        throwsA(isA<Exception>()),
      );
    });
  });
}

class MockUserCredential extends Mock implements UserCredential {}
