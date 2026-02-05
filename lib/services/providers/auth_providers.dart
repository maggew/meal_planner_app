import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meal_planner/domain/exceptions/auth_exceptions.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn.instance;
});

final authStateProvider = StreamProvider<String?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges();
});

// final isSignedInProvider = Provider<bool>((ref) {
//   final authRepo = ref.watch(authRepositoryProvider);
//   return authRepo.isSignedIn;
// });

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(ref),
);

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final uid = await authRepo.signInWithEmail(
        email: email,
        password: password,
      );

      print("login returned: $uid");

      await _ref.read(sessionProvider.notifier).loadSession(uid);

      final session = _ref.read(sessionProvider);
      print("Session nach loadSession: ${session.userId}");

      state = const AsyncValue.data(null);
    } on AuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final userId = await authRepo.signInWithGoogle();
      print("signInWithGoogle returned: $userId");

      await _ref.read(sessionProvider.notifier).loadSession(userId);

      final session = _ref.read(sessionProvider);
      print("Session nach loadSession: ${session.userId}");

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final uid = await authRepo.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );

      // User in Supabase anlegen
      await _ref.read(userRepositoryProvider).ensureUserExists(uid, name);

      await _ref.read(sessionProvider.notifier).loadSession(uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    try {
      final authRepo = _ref.read(authRepositoryProvider);
      await authRepo.signOut();

      await _ref.read(sessionProvider.notifier).clearSession();

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
