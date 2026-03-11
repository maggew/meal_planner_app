import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/repositories/auth_repository.dart';
import 'package:meal_planner/presentation/login/widgets/login_body.dart';
import 'package:meal_planner/presentation/login/widgets/login_reset_password_widget.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:mocktail/mocktail.dart';

// --- Mocks ---

class MockAuthRepository extends Mock implements AuthRepository {}

// --- Fixtures ---

const _email = 'test@example.com';
const _password = 'secret123';

// --- Helpers ---

Widget _buildResetWidget(
  MockAuthRepository mockRepo, {
  String initialEmail = _email,
}) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
    child: MaterialApp(
      home: Scaffold(
        body: LoginResetPasswordWidget(initialEmail: initialEmail),
      ),
    ),
  );
}

Widget _buildLoginBody(MockAuthRepository mockRepo) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
    child: const MaterialApp(
      home: Scaffold(body: LoginBody()),
    ),
  );
}

// --- Tests ---

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  group('LoginResetPasswordWidget', () {
    testWidgets('zeigt TextButton "Passwort vergessen?"', (tester) async {
      await tester.pumpWidget(_buildResetWidget(mockRepo));

      expect(find.text('Passwort vergessen?'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('öffnet Dialog beim Antippen', (tester) async {
      await tester.pumpWidget(_buildResetWidget(mockRepo));

      await tester.tap(find.text('Passwort vergessen?'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Passwort zurücksetzen'), findsOneWidget);
    });

    testWidgets('Dialog enthält initialEmail vorab befüllt', (tester) async {
      await tester.pumpWidget(_buildResetWidget(mockRepo, initialEmail: _email));

      await tester.tap(find.text('Passwort vergessen?'));
      await tester.pumpAndSettle();

      expect(find.text(_email), findsOneWidget);
    });

    testWidgets('Abbrechen-Button schließt Dialog', (tester) async {
      await tester.pumpWidget(_buildResetWidget(mockRepo));

      await tester.tap(find.text('Passwort vergessen?'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('leere E-Mail: kein sendPasswordResetEmail-Aufruf',
        (tester) async {
      await tester.pumpWidget(_buildResetWidget(mockRepo, initialEmail: ''));

      await tester.tap(find.text('Passwort vergessen?'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Zurücksetzen'));
      await tester.pumpAndSettle();

      verifyNever(() => mockRepo.sendPasswordResetEmail(any()));
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('schließt Dialog und zeigt Erfolgs-SnackBar', (tester) async {
      when(() => mockRepo.sendPasswordResetEmail(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(_buildResetWidget(mockRepo));

      await tester.tap(find.text('Passwort vergessen?'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Zurücksetzen'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find.text(
          'Falls ein Konto mit dieser E-Mail-Adresse existiert, erhältst du in Kürze eine E-Mail.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('zeigt Fehler-SnackBar und lässt Dialog offen bei Exception',
        (tester) async {
      when(() => mockRepo.sendPasswordResetEmail(any()))
          .thenThrow(Exception('network error'));

      await tester.pumpWidget(_buildResetWidget(mockRepo));

      await tester.tap(find.text('Passwort vergessen?'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Zurücksetzen'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('Fehler beim Senden der E-Mail. Bitte versuche es erneut.'),
        findsOneWidget,
      );
    });

    testWidgets('übergibt eingegebene E-Mail an sendPasswordResetEmail',
        (tester) async {
      const changedEmail = 'changed@example.com';
      when(() => mockRepo.sendPasswordResetEmail(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(_buildResetWidget(mockRepo, initialEmail: ''));

      await tester.tap(find.text('Passwort vergessen?'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), changedEmail);
      await tester.tap(find.text('Zurücksetzen'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.sendPasswordResetEmail(changedEmail)).called(1);
    });
  });

  group('LoginBody: Reset-Button Sichtbarkeit', () {
    testWidgets('Reset-Button initial nicht sichtbar', (tester) async {
      await tester.pumpWidget(_buildLoginBody(mockRepo));

      expect(find.byType(LoginResetPasswordWidget), findsNothing);
      expect(find.text('Passwort vergessen?'), findsNothing);
    });

    testWidgets('Reset-Button nach Auth-Fehler sichtbar', (tester) async {
      when(() => mockRepo.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      await tester.pumpWidget(_buildLoginBody(mockRepo));

      await tester.enterText(find.byType(TextField).at(0), _email);
      await tester.enterText(find.byType(TextField).at(1), _password);
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginResetPasswordWidget), findsOneWidget);
      expect(find.text('Passwort vergessen?'), findsOneWidget);
    });
  });
}
