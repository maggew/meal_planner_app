import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meal_planner/domain/repositories/auth_repository.dart';
import 'package:meal_planner/domain/repositories/user_repository.dart';
import 'package:meal_planner/data/repositories/firebase_auth_repository.dart';
import 'package:meal_planner/data/repositories/firebase_user_repository.dart';

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

final currentGroupIdStateProvider = StateProvider<String>((ref) => '');

final loadGroupIdProvider = FutureProvider<String>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final userId = authRepo.getCurrentUserId();

  if (userId == null || userId.isEmpty) {
    return '';
  }

  final userRepo = ref.watch(userRepositoryProvider);
  final groupId = await userRepo.getCurrentGroupId(userId);

  if (groupId != null && groupId.isNotEmpty) {
    ref.read(currentGroupIdStateProvider.notifier).state = groupId;
  }

  return groupId ?? '';
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

      final userRepo = _ref.read(userRepositoryProvider);
      final groupId = await userRepo.getCurrentGroupId(uid);

      if (groupId != null && groupId.isNotEmpty) {
        _ref.read(currentGroupIdStateProvider.notifier).state = groupId;
      } else {}

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

      // GroupId löschen
      _ref.read(currentGroupIdStateProvider.notifier).state = '';

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
