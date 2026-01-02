import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meal_planner/domain/repositories/auth_repository.dart';
import 'package:meal_planner/domain/repositories/user_repository.dart';
import 'package:meal_planner/data/repositories/firebase_auth_repository.dart';
import 'package:meal_planner/data/repositories/firebase_user_repository.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository(
    firestore: FirebaseFirestore.instance,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

final currentUserIdProvider = StreamProvider<String?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges();
});

final isSignedInProvider = Provider<bool>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.isSignedIn;
});

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

      await _ref.read(sessionProvider.notifier).loadSession(uid);

      state = const AsyncValue.data(null);
    } on AuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    try {
      final authRepo = _ref.read(authRepositoryProvider);
      await authRepo.signOut();

      _ref.read(sessionProvider.notifier).clearSession();

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
