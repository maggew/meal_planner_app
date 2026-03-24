import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meal_planner/data/repositories/firebase_auth_repository.dart';
import 'package:meal_planner/domain/exceptions/auth_exceptions.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';
import 'package:meal_planner/domain/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────────

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockFirebaseUser extends Mock implements User {}

class MockUserRepository extends Mock implements UserRepository {}

class MockStorageRepository extends Mock implements StorageRepository {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockDio extends Mock implements Dio {}

class FakeAuthCredential extends Fake implements AuthCredential {}

// ─── Helpers ─────────────────────────────────────────────────────────────────

const _email = 'alice@test.com';
const _password = 'secret123';
const _name = 'Alice';
const _supabaseUserId = 'sb-user-id';
const _firebaseToken = 'firebase-id-token';

Response<dynamic> _successResponse(Map<String, dynamic> data) => Response(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockFirebaseAuth auth;
  late MockUserRepository userRepo;
  late MockStorageRepository storage;
  late MockGoogleSignIn googleSignIn;
  late MockDio dio;
  late FirebaseAuthRepository repo;

  setUpAll(() async {
    registerFallbackValue(FakeAuthCredential());
    registerFallbackValue(File(''));
  });

  setUp(() {
    auth = MockFirebaseAuth();
    userRepo = MockUserRepository();
    storage = MockStorageRepository();
    googleSignIn = MockGoogleSignIn();
    dio = MockDio();
    repo = FirebaseAuthRepository(
      auth: auth,
      userRepository: userRepo,
      googleSignIn: googleSignIn,
      dio: dio,
      storageRepository: storage,
    );
  });

  // ── signOut ─────────────────────────────────────────────────────────────────

  group('signOut', () {
    test('completes on success', () async {
      when(() => auth.signOut()).thenAnswer((_) async {});
      await expectLater(repo.signOut(), completes);
    });

    test('throws AuthException on error', () async {
      when(() => auth.signOut()).thenThrow(Exception('sign out failed'));
      await expectLater(repo.signOut(), throwsA(isA<AuthException>()));
    });
  });

  // ── getCurrentUserId ────────────────────────────────────────────────────────

  group('getCurrentUserId', () {
    test('returns null when not signed in', () {
      when(() => auth.currentUser).thenReturn(null);
      expect(repo.getCurrentUserId(), isNull);
    });

    test('returns uid when signed in', () {
      final mockUser = MockFirebaseUser();
      when(() => auth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('firebase-uid-123');
      expect(repo.getCurrentUserId(), 'firebase-uid-123');
    });
  });

  // ── authStateChanges ────────────────────────────────────────────────────────

  group('authStateChanges', () {
    test('emits null when user is signed out', () async {
      when(() => auth.authStateChanges())
          .thenAnswer((_) => Stream.value(null));
      expect(await repo.authStateChanges().first, isNull);
    });

    test('emits uid when user is signed in', () async {
      final mockUser = MockFirebaseUser();
      when(() => mockUser.uid).thenReturn('uid-42');
      when(() => auth.authStateChanges())
          .thenAnswer((_) => Stream.value(mockUser));
      expect(await repo.authStateChanges().first, 'uid-42');
    });
  });

  // ── isSignedIn ──────────────────────────────────────────────────────────────

  group('isSignedIn', () {
    test('returns false when no current user', () {
      when(() => auth.currentUser).thenReturn(null);
      expect(repo.isSignedIn, false);
    });

    test('returns true when current user exists', () {
      final mockUser = MockFirebaseUser();
      when(() => auth.currentUser).thenReturn(mockUser);
      expect(repo.isSignedIn, true);
    });
  });

  // ── registerWithEmail ───────────────────────────────────────────────────────

  group('registerWithEmail', () {
    void _stubSuccessfulRegistration() {
      final mockCred = MockUserCredential();
      final mockUser = MockFirebaseUser();
      when(() => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCred);
      when(() => mockCred.user).thenReturn(mockUser);
      when(() => mockUser.getIdToken(any()))
          .thenAnswer((_) async => _firebaseToken);
      when(() => dio.post(any(),
              options: any(named: 'options'),
              data: any(named: 'data')))
          .thenAnswer((_) async =>
              _successResponse({'user_id': _supabaseUserId}));
    }

    test('returns supabase user id on success', () async {
      _stubSuccessfulRegistration();
      final id = await repo.registerWithEmail(
          name: _name, email: _email, password: _password, image: null);
      expect(id, _supabaseUserId);
    });

    test('throws AuthException for weak-password', () async {
      when(() => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'weak-password'));
      await expectLater(
          repo.registerWithEmail(
              name: _name, email: _email, password: _password, image: null),
          throwsA(isA<AuthException>()));
    });

    test('throws AuthException for email-already-in-use', () async {
      when(() => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      await expectLater(
          repo.registerWithEmail(
              name: _name, email: _email, password: _password, image: null),
          throwsA(isA<AuthException>()));
    });

    test('throws AuthException for invalid-email', () async {
      when(() => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'invalid-email'));
      await expectLater(
          repo.registerWithEmail(
              name: _name, email: _email, password: _password, image: null),
          throwsA(isA<AuthException>()));
    });

    test('throws AuthException for any other FirebaseAuthException', () async {
      when(() => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
              FirebaseAuthException(code: 'unknown', message: 'Unknown'));
      await expectLater(
          repo.registerWithEmail(
              name: _name, email: _email, password: _password, image: null),
          throwsA(isA<AuthException>()));
    });

    test('throws AuthException on generic error', () async {
      when(() => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('network error'));
      await expectLater(
          repo.registerWithEmail(
              name: _name, email: _email, password: _password, image: null),
          throwsA(isA<AuthException>()));
    });

    test('throws AuthException when user is null after registration', () async {
      final mockCred = MockUserCredential();
      when(() => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCred);
      when(() => mockCred.user).thenReturn(null);

      await expectLater(
          repo.registerWithEmail(
              name: _name, email: _email, password: _password, image: null),
          throwsA(isA<AuthException>()));
    });

    test('throws AuthException when Dio bootstrap call fails', () async {
      final mockCred = MockUserCredential();
      final mockUser = MockFirebaseUser();
      when(() => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCred);
      when(() => mockCred.user).thenReturn(mockUser);
      when(() => mockUser.getIdToken(any()))
          .thenAnswer((_) async => _firebaseToken);
      when(() => dio.post(any(),
              options: any(named: 'options'),
              data: any(named: 'data')))
          .thenThrow(
              DioException(requestOptions: RequestOptions(path: '')));

      await expectLater(
          repo.registerWithEmail(
              name: _name, email: _email, password: _password, image: null),
          throwsA(isA<AuthException>()));
    });

    test('image != null, upload erfolgreich → updateUserImage wird aufgerufen',
        () async {
      final mockCred = MockUserCredential();
      final mockUser = MockFirebaseUser();
      when(() => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCred);
      when(() => mockCred.user).thenReturn(mockUser);
      when(() => mockUser.getIdToken(any()))
          .thenAnswer((_) async => _firebaseToken);
      when(() => dio.post(any(),
              options: any(named: 'options'),
              data: any(named: 'data')))
          .thenAnswer(
              (_) async => _successResponse({'user_id': _supabaseUserId}));
      when(() => storage.uploadImage(any(), any()))
          .thenAnswer((_) async => 'https://img.example.com/photo.jpg');
      when(() => userRepo.updateUserImage(
              uid: any(named: 'uid'), imageUrl: any(named: 'imageUrl')))
          .thenAnswer((_) async {});

      final id = await repo.registerWithEmail(
          name: _name,
          email: _email,
          password: _password,
          image: File('avatar.jpg'));

      expect(id, _supabaseUserId);
      verify(() => userRepo.updateUserImage(
          uid: _supabaseUserId,
          imageUrl: 'https://img.example.com/photo.jpg')).called(1);
    });

    test(
        'image != null, uploadImage wirft → catch-Block swallowed, userId wird trotzdem zurückgegeben',
        () async {
      final mockCred = MockUserCredential();
      final mockUser = MockFirebaseUser();
      when(() => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCred);
      when(() => mockCred.user).thenReturn(mockUser);
      when(() => mockUser.getIdToken(any()))
          .thenAnswer((_) async => _firebaseToken);
      when(() => dio.post(any(),
              options: any(named: 'options'),
              data: any(named: 'data')))
          .thenAnswer(
              (_) async => _successResponse({'user_id': _supabaseUserId}));
      when(() => storage.uploadImage(any(), any()))
          .thenThrow(Exception('upload failed'));

      final id = await repo.registerWithEmail(
          name: _name,
          email: _email,
          password: _password,
          image: File('avatar.jpg'));

      expect(id, _supabaseUserId);
    });
  });

  // ── signInWithEmail ─────────────────────────────────────────────────────────

  group('signInWithEmail', () {
    void _stubSuccessfulSignIn() {
      final mockCred = MockUserCredential();
      final mockUser = MockFirebaseUser();
      when(() => auth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCred);
      when(() => mockCred.user).thenReturn(mockUser);
      when(() => mockUser.getIdToken(any()))
          .thenAnswer((_) async => _firebaseToken);
      when(() => dio.post(any(),
              options: any(named: 'options'),
              data: any(named: 'data')))
          .thenAnswer((_) async =>
              _successResponse({'user_id': _supabaseUserId}));
    }

    test('returns supabase user id on success', () async {
      _stubSuccessfulSignIn();
      final id = await repo.signInWithEmail(email: _email, password: _password);
      expect(id, _supabaseUserId);
    });

    test('throws AuthException for user-not-found', () async {
      when(() => auth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'user-not-found'));
      await expectLater(
          repo.signInWithEmail(email: _email, password: _password),
          throwsA(isA<AuthException>()));
    });

    test('throws AuthException for wrong-password', () async {
      when(() => auth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'wrong-password'));
      await expectLater(
          repo.signInWithEmail(email: _email, password: _password),
          throwsA(isA<AuthException>()));
    });

    test('throws AuthException for user-disabled', () async {
      when(() => auth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'user-disabled'));
      await expectLater(
          repo.signInWithEmail(email: _email, password: _password),
          throwsA(isA<AuthException>()));
    });

    test('throws AuthException on generic error', () async {
      when(() => auth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('network error'));
      await expectLater(
          repo.signInWithEmail(email: _email, password: _password),
          throwsA(isA<AuthException>()));
    });

    test('throws AuthException when user is null after sign-in', () async {
      final mockCred = MockUserCredential();
      when(() => auth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCred);
      when(() => mockCred.user).thenReturn(null);

      await expectLater(
          repo.signInWithEmail(email: _email, password: _password),
          throwsA(isA<AuthException>()));
    });

    test('throws AuthException when Dio bootstrap call fails', () async {
      final mockCred = MockUserCredential();
      final mockUser = MockFirebaseUser();
      when(() => auth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCred);
      when(() => mockCred.user).thenReturn(mockUser);
      when(() => mockUser.getIdToken(any()))
          .thenAnswer((_) async => _firebaseToken);
      when(() => dio.post(any(),
              options: any(named: 'options'),
              data: any(named: 'data')))
          .thenThrow(
              DioException(requestOptions: RequestOptions(path: '')));

      await expectLater(
          repo.signInWithEmail(email: _email, password: _password),
          throwsA(isA<AuthException>()));
    });

    test('throws AuthException for invalid-email', () async {
      when(() => auth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'invalid-email'));
      await expectLater(
          repo.signInWithEmail(email: _email, password: _password),
          throwsA(isA<AuthException>()));
    });

    test('throws AuthException for unbekannten FirebaseAuthException Code (default branch)',
        () async {
      when(() => auth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
              FirebaseAuthException(code: 'too-many-requests', message: 'Rate limited'));
      await expectLater(
          repo.signInWithEmail(email: _email, password: _password),
          throwsA(isA<AuthException>()));
    });
  });

  // ── signInWithGoogle ────────────────────────────────────────────────────────

  group('signInWithGoogle', () {
    test(
        'throws AuthException when device does not support Google Sign-In',
        () async {
      when(() => googleSignIn.initialize(
              serverClientId: any(named: 'serverClientId')))
          .thenAnswer((_) async {});
      when(() => googleSignIn.supportsAuthenticate()).thenReturn(false);

      await expectLater(
          repo.signInWithGoogle(), throwsA(isA<AuthException>()));
    });

    test(
        'throws AuthException with "google auth cancelled" on sign_in_cancelled',
        () async {
      when(() => googleSignIn.initialize(
              serverClientId: any(named: 'serverClientId')))
          .thenAnswer((_) async {});
      when(() => googleSignIn.supportsAuthenticate()).thenReturn(true);
      when(() => googleSignIn.authenticate()).thenThrow(
          PlatformException(code: 'sign_in_cancelled'));

      await expectLater(
          repo.signInWithGoogle(),
          throwsA(isA<AuthException>().having(
              (e) => e.message, 'message', contains('cancelled'))));
    });

    test('throws AuthException on any generic error in Google Sign-In',
        () async {
      when(() => googleSignIn.initialize(
              serverClientId: any(named: 'serverClientId')))
          .thenThrow(Exception('initialization failed'));

      await expectLater(
          repo.signInWithGoogle(), throwsA(isA<AuthException>()));
    });

    test('throws AuthException when idToken is null', () async {
      final gUser = MockGoogleSignInAccount();
      final gAuth = MockGoogleSignInAuthentication();
      when(() => googleSignIn.initialize(
              serverClientId: any(named: 'serverClientId')))
          .thenAnswer((_) async {});
      when(() => googleSignIn.supportsAuthenticate()).thenReturn(true);
      when(() => googleSignIn.authenticate()).thenAnswer((_) async => gUser);
      when(() => gUser.authentication).thenReturn(gAuth);
      when(() => gAuth.idToken).thenReturn(null);

      await expectLater(
          repo.signInWithGoogle(),
          throwsA(isA<AuthException>().having(
              (e) => e.message, 'message', contains('idToken is null'))));
    });

    test('throws AuthException when Firebase user is null after signInWithCredential',
        () async {
      final gUser = MockGoogleSignInAccount();
      final gAuth = MockGoogleSignInAuthentication();
      final cred = MockUserCredential();
      when(() => googleSignIn.initialize(
              serverClientId: any(named: 'serverClientId')))
          .thenAnswer((_) async {});
      when(() => googleSignIn.supportsAuthenticate()).thenReturn(true);
      when(() => googleSignIn.authenticate()).thenAnswer((_) async => gUser);
      when(() => gUser.authentication).thenReturn(gAuth);
      when(() => gAuth.idToken).thenReturn('google-id-token');
      when(() => auth.signInWithCredential(any())).thenAnswer((_) async => cred);
      when(() => cred.user).thenReturn(null);

      await expectLater(
          repo.signInWithGoogle(), throwsA(isA<AuthException>()));
    });

    test('success, kein photoUrl → kein updateUserImage, gibt userId zurück',
        () async {
      final gUser = MockGoogleSignInAccount();
      final gAuth = MockGoogleSignInAuthentication();
      final cred = MockUserCredential();
      final fbUser = MockFirebaseUser();
      when(() => googleSignIn.initialize(
              serverClientId: any(named: 'serverClientId')))
          .thenAnswer((_) async {});
      when(() => googleSignIn.supportsAuthenticate()).thenReturn(true);
      when(() => googleSignIn.authenticate()).thenAnswer((_) async => gUser);
      when(() => gUser.authentication).thenReturn(gAuth);
      when(() => gAuth.idToken).thenReturn('google-id-token');
      when(() => auth.signInWithCredential(any())).thenAnswer((_) async => cred);
      when(() => cred.user).thenReturn(fbUser);
      when(() => fbUser.getIdToken(any())).thenAnswer((_) async => _firebaseToken);
      when(() => gUser.photoUrl).thenReturn(null);
      when(() => dio.post(any(),
              options: any(named: 'options'),
              data: any(named: 'data')))
          .thenAnswer((_) async => _successResponse({
                'user_id': _supabaseUserId,
                'image_url': null,
              }));

      final id = await repo.signInWithGoogle();
      expect(id, _supabaseUserId);
      verifyNever(() => userRepo.updateUserImage(
          uid: any(named: 'uid'), imageUrl: any(named: 'imageUrl')));
    });

    test('success, photoUrl gesetzt + kein existingImage → updateUserImage wird aufgerufen',
        () async {
      final gUser = MockGoogleSignInAccount();
      final gAuth = MockGoogleSignInAuthentication();
      final cred = MockUserCredential();
      final fbUser = MockFirebaseUser();
      when(() => googleSignIn.initialize(
              serverClientId: any(named: 'serverClientId')))
          .thenAnswer((_) async {});
      when(() => googleSignIn.supportsAuthenticate()).thenReturn(true);
      when(() => googleSignIn.authenticate()).thenAnswer((_) async => gUser);
      when(() => gUser.authentication).thenReturn(gAuth);
      when(() => gAuth.idToken).thenReturn('google-id-token');
      when(() => auth.signInWithCredential(any())).thenAnswer((_) async => cred);
      when(() => cred.user).thenReturn(fbUser);
      when(() => fbUser.getIdToken(any())).thenAnswer((_) async => _firebaseToken);
      when(() => gUser.photoUrl).thenReturn('https://google-photo.com/photo.jpg');
      when(() => dio.post(any(),
              options: any(named: 'options'),
              data: any(named: 'data')))
          .thenAnswer((_) async => _successResponse({
                'user_id': _supabaseUserId,
                'image_url': null,
              }));
      when(() => userRepo.updateUserImage(
              uid: any(named: 'uid'), imageUrl: any(named: 'imageUrl')))
          .thenAnswer((_) async {});

      final id = await repo.signInWithGoogle();
      expect(id, _supabaseUserId);
      verify(() => userRepo.updateUserImage(
          uid: _supabaseUserId,
          imageUrl: 'https://google-photo.com/photo.jpg')).called(1);
    });

    test(
        'success, photoUrl gesetzt + existingImage leer → updateUserImage wird aufgerufen',
        () async {
      final gUser = MockGoogleSignInAccount();
      final gAuth = MockGoogleSignInAuthentication();
      final cred = MockUserCredential();
      final fbUser = MockFirebaseUser();
      when(() => googleSignIn.initialize(
              serverClientId: any(named: 'serverClientId')))
          .thenAnswer((_) async {});
      when(() => googleSignIn.supportsAuthenticate()).thenReturn(true);
      when(() => googleSignIn.authenticate()).thenAnswer((_) async => gUser);
      when(() => gUser.authentication).thenReturn(gAuth);
      when(() => gAuth.idToken).thenReturn('google-id-token');
      when(() => auth.signInWithCredential(any())).thenAnswer((_) async => cred);
      when(() => cred.user).thenReturn(fbUser);
      when(() => fbUser.getIdToken(any())).thenAnswer((_) async => _firebaseToken);
      when(() => gUser.photoUrl).thenReturn('https://google-photo.com/photo.jpg');
      when(() => dio.post(any(),
              options: any(named: 'options'),
              data: any(named: 'data')))
          .thenAnswer((_) async => _successResponse({
                'user_id': _supabaseUserId,
                'image_url': '',
              }));
      when(() => userRepo.updateUserImage(
              uid: any(named: 'uid'), imageUrl: any(named: 'imageUrl')))
          .thenAnswer((_) async {});

      final id = await repo.signInWithGoogle();
      expect(id, _supabaseUserId);
      verify(() => userRepo.updateUserImage(
          uid: _supabaseUserId,
          imageUrl: 'https://google-photo.com/photo.jpg')).called(1);
    });

    test(
        'success, photoUrl gesetzt, updateUserImage wirft → catch-Block swallowed, gibt userId zurück',
        () async {
      final gUser = MockGoogleSignInAccount();
      final gAuth = MockGoogleSignInAuthentication();
      final cred = MockUserCredential();
      final fbUser = MockFirebaseUser();
      when(() => googleSignIn.initialize(
              serverClientId: any(named: 'serverClientId')))
          .thenAnswer((_) async {});
      when(() => googleSignIn.supportsAuthenticate()).thenReturn(true);
      when(() => googleSignIn.authenticate()).thenAnswer((_) async => gUser);
      when(() => gUser.authentication).thenReturn(gAuth);
      when(() => gAuth.idToken).thenReturn('google-id-token');
      when(() => auth.signInWithCredential(any())).thenAnswer((_) async => cred);
      when(() => cred.user).thenReturn(fbUser);
      when(() => fbUser.getIdToken(any())).thenAnswer((_) async => _firebaseToken);
      when(() => gUser.photoUrl).thenReturn('https://google-photo.com/photo.jpg');
      when(() => dio.post(any(),
              options: any(named: 'options'),
              data: any(named: 'data')))
          .thenAnswer((_) async => _successResponse({
                'user_id': _supabaseUserId,
                'image_url': null,
              }));
      when(() => userRepo.updateUserImage(
              uid: any(named: 'uid'), imageUrl: any(named: 'imageUrl')))
          .thenThrow(Exception('update failed'));

      final id = await repo.signInWithGoogle();
      expect(id, _supabaseUserId);
    });
  });

  // ── sendPasswordResetEmail ──────────────────────────────────────────────────

  group('sendPasswordResetEmail', () {
    test('completes und ruft Firebase mit korrekter E-Mail auf', () async {
      when(() => auth.sendPasswordResetEmail(email: any(named: 'email')))
          .thenAnswer((_) async {});

      await repo.sendPasswordResetEmail(_email);

      verify(() => auth.sendPasswordResetEmail(email: _email)).called(1);
    });

    test('propagiert FirebaseAuthException', () async {
      when(() => auth.sendPasswordResetEmail(email: any(named: 'email')))
          .thenThrow(FirebaseAuthException(code: 'invalid-email'));

      await expectLater(
        repo.sendPasswordResetEmail('ungueltig'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });
}
