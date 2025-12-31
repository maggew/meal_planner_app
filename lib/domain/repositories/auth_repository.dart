abstract class AuthRepository {
  Future<String> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<String> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  String? getCurrentUserId();

  Stream<String?> authStateChanges();

  bool get isSignedIn;
}
