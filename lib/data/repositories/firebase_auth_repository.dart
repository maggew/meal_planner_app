// lib/data/repositories/firebase_auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meal_planner/domain/repositories/auth_repository.dart';
import 'package:meal_planner/domain/repositories/user_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth auth;
  final UserRepository userRepository;

  FirebaseAuthRepository({
    required this.auth,
    required this.userRepository,
  });

  @override
  Future<String> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      await userRepository.createUser(uid: uid, name: name, email: email);

      return uid;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw AuthException('Das Passwort ist zu schwach');
        case 'email-already-in-use':
          throw AuthException(
              'Ein Account mit dieser E-Mail existiert bereits');
        case 'invalid-email':
          throw AuthException('Ungültige E-Mail-Adresse');
        default:
          throw AuthException('Registrierung fehlgeschlagen: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Unerwarteter Fehler bei der Registrierung: $e');
    }
  }

  @override
  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('Kein Account mit dieser E-Mail gefunden');
        case 'wrong-password':
          throw AuthException('Falsches Passwort');
        case 'invalid-email':
          throw AuthException('Ungültige E-Mail-Adresse');
        case 'user-disabled':
          throw AuthException('Dieser Account wurde deaktiviert');
        default:
          throw AuthException('Login fehlgeschlagen: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Unerwarteter Fehler beim Login: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      throw AuthException('Logout fehlgeschlagen: $e');
    }
  }

  @override
  String? getCurrentUserId() {
    return auth.currentUser?.uid;
  }

  @override
  Stream<String?> authStateChanges() {
    return auth.authStateChanges().map((user) => user?.uid);
  }

  @override
  bool get isSignedIn => auth.currentUser != null;
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
