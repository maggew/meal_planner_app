import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meal_planner/services/auth.dart';

final authProvider = Provider<Auth>((ref) {
  return Auth();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(ref.read(authProvider)),
);

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._auth) : super(const AsyncValue.data(null));

  final Auth _auth;

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      print("in loginState");
      await _auth.signInWithEmail(email, password);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
