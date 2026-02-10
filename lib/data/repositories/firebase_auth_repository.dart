// lib/data/repositories/firebase_auth_repository.dart
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meal_planner/core/constants/firebase_constants.dart';
import 'package:meal_planner/domain/exceptions/auth_exceptions.dart';
import 'package:meal_planner/domain/repositories/auth_repository.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';
import 'package:meal_planner/domain/repositories/user_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final UserRepository _userRepository;
  final StorageRepository _storageRepository;
  final GoogleSignIn _googleSignIn;
  final Dio _dio;

  FirebaseAuthRepository({
    required FirebaseAuth auth,
    required UserRepository userRepository,
    required GoogleSignIn googleSignIn,
    required Dio dio,
    required StorageRepository storageRepository,
  })  : _storageRepository = storageRepository,
        _dio = dio,
        _googleSignIn = googleSignIn,
        _userRepository = userRepository,
        _auth = auth;

  @override
  Future<String> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required File? image,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException("User konnte nicht erstellt werden");
      }

      final firebaseIdToken = await user.getIdToken();

      final supabaseResponse = await _dio.post(
        'https://esreihfibhoueesrlmxj.functions.supabase.co/bootstrap-user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $firebaseIdToken',
          },
        ),
        data: {'name': name},
      );

      final supabaseUserId = supabaseResponse.data['user_id'] as String;

      if (image != null) {
        try {
          final imageUrl = await _storageRepository.uploadImage(
              image, FirebaseConstants.imageUser);

          await _userRepository.updateUserImage(
              uid: supabaseUserId, imageUrl: imageUrl);
        } catch (e) {
          print('Profilbild konnte nicht gespeichert werden: $e');
        }
      }

      return supabaseUserId;
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
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Login fehlgeschlagen');
      }

      // Supabase User ID holen (wie bei Google Login)
      final firebaseIdToken = await user.getIdToken();
      final supabaseResponse = await _dio.post(
        'https://esreihfibhoueesrlmxj.functions.supabase.co/bootstrap-user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $firebaseIdToken',
          },
        ),
      );
      final supabaseUserId = supabaseResponse.data['user_id'] as String;
      return supabaseUserId;
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
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Logout fehlgeschlagen: $e');
    }
  }

  @override
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  @override
  Stream<String?> authStateChanges() {
    return _auth.authStateChanges().map((user) => user?.uid);
  }

  @override
  bool get isSignedIn => _auth.currentUser != null;

  @override
  Future<String> signInWithGoogle() async {
    try {
      final signIn = _googleSignIn;

      await signIn.initialize(
        serverClientId: dotenv.env['GOOGLE_LOGIN_SERVER_CLIENT_ID'],
      );

      if (!signIn.supportsAuthenticate()) {
        throw AuthException("Google Sign-In not supported on this device");
      }

      final googleUser = await signIn.authenticate();

      final googleAuth = googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw AuthException("Google idToken is null");
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      final user = result.user;
      if (user == null) {
        throw AuthException("Unknown error in with googleAuth");
      }

      final firebaseIdToken = await user.getIdToken();

      final supabaseResponse = await _dio.post(
        'https://esreihfibhoueesrlmxj.functions.supabase.co/bootstrap-user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $firebaseIdToken',
          },
        ),
      );

      final supabaseUserId = supabaseResponse.data['user_id'] as String;
      final imageUrl = googleUser.photoUrl;

      if (imageUrl != null) {
        try {
          await _userRepository.updateUserImage(
              uid: supabaseUserId, imageUrl: imageUrl);
        } catch (e) {
          print('Google-Profilbild konnte nicht gespeichert werden: $e');
        }
      }
      return supabaseUserId;
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_cancelled') {
        throw AuthException("google auth cancelled");
      }
      rethrow;
    } catch (e) {
      print(e);
      throw AuthException("Unknown error in with googleAuth");
    }
  }
}
