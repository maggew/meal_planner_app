import 'dart:io';

abstract class AuthRepository {
  Future<String> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required File? image,
  });

  Future<String> signInWithEmail({
    required String email,
    required String password,
  });

  Future<String> signInWithGoogle();

  Future<void> signOut();

  String? getCurrentUserId();

  Stream<String?> authStateChanges();

  bool get isSignedIn;
}
