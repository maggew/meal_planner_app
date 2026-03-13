import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_body.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

// --- Fake Notifier ---

/// Ersetzt ImageManager im Test und zeichnet auf, ob cleanupPendingPhoto
/// aufgerufen wurde. Triggert keinen echten Firebase-Upload.
class FakeImageManager extends ImageManager {
  bool cleanupCalled = false;

  @override
  CustomImages build() => const CustomImages();

  @override
  Future<void> cleanupPendingPhoto() async {
    cleanupCalled = true;
  }
}

// --- Helper ---

Widget _buildBody(FakeImageManager fakeImageManager) {
  return ProviderScope(
    overrides: [
      imageManagerProvider.overrideWith(() => fakeImageManager),
      // groupCategoriesProvider wertet groupId aus: null → gibt sofort [] zurück
      sessionProvider.overrideWithValue(const SessionState()),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: AddEditRecipeBody(existingRecipe: null),
      ),
    ),
  );
}

// --- Tests ---

void main() {
  group('AddEditRecipeBody dispose', () {
    testWidgets('ruft cleanupPendingPhoto auf wenn die Seite verlassen wird',
        (tester) async {
      final fake = FakeImageManager();

      // Widget aufbauen
      await tester.pumpWidget(_buildBody(fake));
      await tester.pump();

      expect(fake.cleanupCalled, isFalse);

      // Widget entfernen → dispose() wird aufgerufen
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(fake.cleanupCalled, isTrue);
    });

    testWidgets(
        'ruft cleanupPendingPhoto auch dann auf wenn kein Foto ausgewählt wurde',
        (tester) async {
      final fake = FakeImageManager();

      await tester.pumpWidget(_buildBody(fake));
      await tester.pump();
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // cleanupPendingPhoto wird immer aufgerufen — die Methode selbst ist ein No-op
      // wenn kein Foto gesetzt ist (getestet in image_manager_provider_test.dart)
      expect(fake.cleanupCalled, isTrue);
    });
  });
}
