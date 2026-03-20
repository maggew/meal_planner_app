import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_instructions.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';

// --- Fakes ---

class FakeImageManager extends ImageManager {
  @override
  CustomImages build() => const CustomImages();

  @override
  Future<void> cleanupPendingPhoto() async {}
}

// --- Helper ---

/// Baut das Instructions-Widget isoliert — ohne die ganze
/// AddEditRecipeBody, damit es im Test-Viewport sichtbar ist.
Widget _buildInstructionsWidget({String initialText = ''}) {
  final controller = TextEditingController(text: initialText);
  return ProviderScope(
    overrides: [
      imageManagerProvider.overrideWith(() => FakeImageManager()),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AddEditRecipeInstructions(
            recipeInstructionsController: controller,
          ),
        ),
      ),
    ),
  );
}

/// Findet das EditableText innerhalb des Instructions-Widgets.
Finder _editableText() => find.byType(EditableText);

/// Findet das TextFormField.
Finder _textFormField() => find.byType(TextFormField);

// --- Tests ---

void main() {
  setUp(() {
    // Global notifier zurücksetzen, damit Tests unabhängig sind.
    excludeInstructionsFocusNotifier.value = false;
  });

  group('Instructions TextFormField — Tap- und Selektionsverhalten', () {
    testWidgets('Tap auf leeres Feld gibt Fokus ohne Selektion',
        (tester) async {
      await tester.pumpWidget(_buildInstructionsWidget());
      await tester.pumpAndSettle();

      await tester.tap(_textFormField());
      await tester.pumpAndSettle();

      final editable = tester.widget<EditableText>(_editableText());
      final selection = editable.controller.selection;

      // Cursor sollte collapsed sein (keine Range-Selektion)
      expect(selection.isValid, isTrue);
      expect(
        selection.isCollapsed,
        isTrue,
        reason: 'Nach einem einzelnen Tap sollte kein Text markiert sein',
      );
    });

    testWidgets('Tap in Feld mit Text platziert Cursor ohne Markierung',
        (tester) async {
      const testText = 'Schritt 1: Zwiebeln schneiden\n'
          'Schritt 2: Öl erhitzen\n'
          'Schritt 3: Anbraten';
      await tester.pumpWidget(
        _buildInstructionsWidget(initialText: testText),
      );
      await tester.pumpAndSettle();

      // Tap auf das Feld
      await tester.tap(_textFormField());
      await tester.pumpAndSettle();

      final editable = tester.widget<EditableText>(_editableText());
      final selection = editable.controller.selection;

      expect(
        selection.isCollapsed,
        isTrue,
        reason: 'Einzelner Tap sollte nur Cursor platzieren, '
            'nicht Text markieren',
      );
    });

    // Doppel-Tap-Wort-Selektion ist Flutter-internes Verhalten und
    // lässt sich im Test-Framework nicht zuverlässig simulieren.
    // Auf echten Geräten funktioniert es korrekt.

    testWidgets(
        'Nach Fokus-Verlust und erneutem Tap: Cursor, keine Selektion',
        (tester) async {
      // Baue ein Setup mit 2 Textfeldern, um Fokus-Wechsel zu simulieren
      final instructionsCtrl =
          TextEditingController(text: 'Reis kochen und abkühlen lassen');
      final otherCtrl = TextEditingController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            imageManagerProvider.overrideWith(() => FakeImageManager()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // Anderes Textfeld zum Fokus-Wechseln
                  TextField(
                    controller: otherCtrl,
                    decoration:
                        const InputDecoration(hintText: 'Anderes Feld'),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AddEditRecipeInstructions(
                        recipeInstructionsController: instructionsCtrl,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1) Instructions fokussieren
      await tester.tap(_textFormField().last);
      await tester.pumpAndSettle();

      // 2) Fokus weg: auf das andere Feld tippen
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();

      // 3) Zurück auf Instructions tippen
      await tester.tap(_textFormField().last);
      await tester.pumpAndSettle();

      final editable = tester.widgetList<EditableText>(
        _editableText(),
      );
      // Das Instructions-Feld ist das mit dem Reis-Text
      final instructionsEditable = editable.firstWhere(
        (e) => e.controller.text.contains('Reis'),
      );

      expect(
        instructionsEditable.controller.selection.isCollapsed,
        isTrue,
        reason: 'Nach Fokus-Verlust und erneutem Tap sollte nur der '
            'Cursor platziert werden, nicht Text markiert',
      );
    });

    testWidgets('maxLines ist null — Feld wächst statt intern zu scrollen',
        (tester) async {
      await tester.pumpWidget(_buildInstructionsWidget());
      await tester.pumpAndSettle();

      final editable = tester.widget<EditableText>(_editableText());
      expect(
        editable.maxLines,
        isNull,
        reason: 'maxLines muss null sein, damit das Feld wächst',
      );
    });

    testWidgets('Langer Text: kein internes Scrolling im Textfeld',
        (tester) async {
      final longText = List.generate(
        30,
        (i) => 'Schritt ${i + 1}: Längere Beschreibung für diesen '
            'Kochschritt mit genug Text.',
      ).join('\n');

      await tester.pumpWidget(
        _buildInstructionsWidget(initialText: longText),
      );
      await tester.pumpAndSettle();

      // Tap → sollte Fokus geben
      await tester.tap(_textFormField(), warnIfMissed: false);
      await tester.pumpAndSettle();

      final editable = tester.widget<EditableText>(_editableText());

      // maxLines: null → das Feld hat kein eigenes Scrolling
      expect(editable.maxLines, isNull);

      // Der Text sollte vollständig im Controller sein
      expect(editable.controller.text, equals(longText));
    });

    testWidgets('excludeInstructionsFocusNotifier blockiert Fokus',
        (tester) async {
      await tester.pumpWidget(_buildInstructionsWidget());
      await tester.pumpAndSettle();

      // Fokus blockieren
      excludeInstructionsFocusNotifier.value = true;
      await tester.pump();

      // Tap sollte keinen Fokus geben
      await tester.tap(_textFormField());
      await tester.pumpAndSettle();

      final editable = tester.widget<EditableText>(_editableText());
      expect(
        editable.focusNode.hasFocus,
        isFalse,
        reason: 'Wenn excludeInstructionsFocusNotifier true ist, '
            'sollte das Feld keinen Fokus erhalten können',
      );
    });

    testWidgets('onTap collapsed bestehende Selektion (Android-Workaround)',
        (tester) async {
      const testText = 'Zwiebeln fein würfeln und anbraten';
      final controller = TextEditingController(text: testText);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            imageManagerProvider.overrideWith(() => FakeImageManager()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AddEditRecipeInstructions(
                recipeInstructionsController: controller,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Simuliere eine "stuck" Selection (wie der Android-Bug)
      controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 8, // "Zwiebeln" markiert
      );
      await tester.pump();

      expect(controller.selection.isCollapsed, isFalse,
          reason: 'Vor-Bedingung: Selection existiert');

      // Tap auf das Feld → onTap sollte die Selection collapsed
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      expect(
        controller.selection.isCollapsed,
        isTrue,
        reason: 'onTap muss eine bestehende Selektion aufheben',
      );
    });

    testWidgets('Nach Freigabe von excludeNotifier kann Fokus wieder erteilt werden',
        (tester) async {
      await tester.pumpWidget(_buildInstructionsWidget());
      await tester.pumpAndSettle();

      // Erst blockieren, dann freigeben
      excludeInstructionsFocusNotifier.value = true;
      await tester.pump();
      excludeInstructionsFocusNotifier.value = false;
      await tester.pump();

      // Jetzt sollte Fokus funktionieren
      await tester.tap(_textFormField());
      await tester.pumpAndSettle();

      final editable = tester.widget<EditableText>(_editableText());
      expect(
        editable.focusNode.hasFocus,
        isTrue,
        reason: 'Nach Freigabe sollte Fokus wieder möglich sein',
      );
    });
  });
}
