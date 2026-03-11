import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_ingredients_list.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_step_indicator.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/timer/cooking_mode_timer_duration_picker.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_cooking_mode.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/recipe_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _recipeId = 'recipe1';

final _testSection = IngredientSection(
  title: '',
  ingredients: [Ingredient(name: 'Nudeln', unit: null, amount: '200')],
);

// Rezept mit 3 nummerierten Schritten
final _normalRecipe = Recipe(
  id: _recipeId,
  name: 'Normales Rezept',
  categories: [],
  portions: 2,
  ingredientSections: [_testSection],
  instructions: '1. Nudeln kochen.\n2. Soße machen.\n3. Servieren.',
);

// Rezept OHNE nummerierte Schritte → _parseInstructions() liefert []
final _unnumberedRecipe = Recipe(
  id: _recipeId,
  name: 'Keine Nummerierung',
  categories: [],
  portions: 2,
  ingredientSections: [_testSection],
  instructions: 'Nudeln kochen. Soße machen. Servieren.',
);

// ignore: prefer_typing_uninitialized_variables
get _timerOverrides => [
      recipeTimersProvider(_recipeId).overrideWith((ref) async => {}),
      activeTimerProvider.overrideWith(ActiveTimerNotifier.new),
      timerTickProvider.overrideWith(TimerTick.new),
    ];

Widget _wrap(Widget child) => ProviderScope(
      overrides: _timerOverrides,
      child: MaterialApp(home: Scaffold(body: child)),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/wakelock'),
      (call) async => null,
    );
  });

  // -------------------------------------------------------------------------
  // Bug #1: Rezept ohne nummerierte Schritte
  // _parseInstructions() → [] → CookingModeStepIndicator(totalSteps: 0)
  // → _buildSimpleRow: List.generate(0 * 2 - 1, ...) = List.generate(-1, ...)
  // → RangeError: Invalid count: -1
  // -------------------------------------------------------------------------
  group('ShowRecipeCookingMode – Rezept ohne nummerierte Schritte', () {
    testWidgets(
      'Bug: kein Crash wenn instructions keine "1. 2. 3."-Nummerierung haben',
      (tester) async {
        await tester.pumpWidget(
          _wrap(ShowRecipeCookingMode(
            recipe: _unnumberedRecipe,
            scaledSections: [_testSection],
          )),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Bug #2: CookingModeStepIndicator direkt mit totalSteps = 0
  // List.generate(0 * 2 - 1, ...) = List.generate(-1, ...) → RangeError
  // -------------------------------------------------------------------------
  group('CookingModeStepIndicator – totalSteps = 0', () {
    testWidgets(
      'Bug: kein Crash bei totalSteps = 0',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CookingModeStepIndicator(
                totalSteps: 0,
                currentStep: 0,
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Bug #3: initialStep mit unnumbered recipe (length = 0)
  // widget.initialStep?.clamp(0, instructions.length - 1)
  // = 5.clamp(0, -1) → ArgumentError: min > max
  // -------------------------------------------------------------------------
  group('ShowRecipeCookingMode – initialStep bei leerer Instructions-Liste', () {
    testWidgets(
      'Bug: kein Crash wenn initialStep gesetzt und instructions leer',
      (tester) async {
        await tester.pumpWidget(
          _wrap(ShowRecipeCookingMode(
            recipe: _unnumberedRecipe,
            scaledSections: [_testSection],
            initialStep: 5,
          )),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'initialStep > Schrittanzahl: kein Crash, landet auf letztem Schritt',
      (tester) async {
        await tester.pumpWidget(
          _wrap(ShowRecipeCookingMode(
            recipe: _normalRecipe,
            scaledSections: [_testSection],
            initialStep: 99,
          )),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        // Schritt 3 (Index 2) ist aktiv – kein check_rounded (noch nicht erledigt)
        expect(find.text('3'), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Bug #4: Schmaler Viewport → RenderFlex-Overflow im TimerDurationPicker
  // Button-Row: 2× Expanded + ConstrainedBox(minWidth: 80) → bei ~120dp eng
  // -------------------------------------------------------------------------
  group('CookingModeTimerDurationPicker – schmaler Viewport', () {
    testWidgets(
      'Bug: kein RenderFlex-Overflow bei 180dp Breite',
      (tester) async {
        addTearDown(tester.view.reset);
        tester.view.physicalSize = const Size(540, 1200); // 180×400 @3x
        tester.view.devicePixelRatio = 3.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CookingModeTimerDurationPicker(
                    labelController: TextEditingController(),
                    minutesController: TextEditingController(),
                    secondsController: TextEditingController(),
                    onStart: () {},
                    onCancel: () {},
                    onSave: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Bug #5: Sekunden-Eingabe > 59 wird nicht validiert
  // Nutzer gibt "90" ein → _parseInput() nimmt 90s still an, kein Hinweis
  // Erwartet: Validierungsfehler ODER automatische Normalisierung auf 1:30
  // -------------------------------------------------------------------------
  group('CookingModeTimerDurationPicker – Sekunden > 59', () {
    testWidgets(
      'Bug: Sekunden-Feld "90" zeigt Validierungsfehler',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CookingModeTimerDurationPicker(
                labelController: TextEditingController(),
                minutesController: TextEditingController(),
                secondsController: TextEditingController(text: '90'),
                onStart: () {},
                onCancel: () {},
                onSave: () {},
              ),
            ),
          ),
        );
        await tester.pump();

        // Erwartet: sichtbarer Fehlerhinweis (z.B. "Max. 59")
        // Aktuell: kein Feedback → dieser Test ist ROT
        expect(
          find.textContaining('59'),
          findsOneWidget,
          reason: 'Sekunden > 59 sollten einen Validierungsfehler zeigen',
        );
      },
    );
  });

  // -------------------------------------------------------------------------
  // Bug #7: Scrollbar bleibt mid-animation sichtbar beim Zuklappen
  // AnimatedCrossFade hält beide Children im Tree während der Animation.
  // Der Scrollbar-Thumb "schwebt" dadurch in der Mitte des Bildschirms,
  // bis die 200ms-Animation abgeschlossen ist.
  // Erwartet: Scrollbar verschwindet sofort beim Zuklappen (nicht nach Animation).
  // -------------------------------------------------------------------------
  group('CookingModeIngredientsList – Scrollbar sichtbarkeit', () {
    testWidgets(
      'Bug: Scrollbar verschwindet sofort beim Zuklappen (nicht mid-animation)',
      (tester) async {
        bool isExpanded = true;

        await tester.pumpWidget(
          ProviderScope(
            overrides: _timerOverrides,
            child: MaterialApp(
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) => CookingModeIngredientsList(
                    isExpanded: isExpanded,
                    onExpandToggle: () =>
                        setState(() => isExpanded = !isExpanded),
                    ingredientSections: [_testSection],
                    recipeId: _recipeId,
                    stepNumber: 0,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Zutatenliste ist offen → Scrollbar im Tree
        expect(find.byType(Scrollbar), findsOneWidget);

        // Zuklappen antippen
        await tester.tap(find.text('Zutaten'));
        // Nur einen Frame pumpen – die 200ms-Animation läuft noch
        await tester.pump();

        // Scrollbar soll SOFORT weg sein, nicht noch mid-animation im Tree bleiben.
        // Aktuell: AnimatedCrossFade hält den zweiten Child (mit Scrollbar) im Tree
        // → Scrollbar noch vorhanden → dieser Test ist ROT.
        expect(find.byType(Scrollbar), findsNothing);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Bug #6: Doppel-Tap auf add_alarm öffnet zwei Bottom Sheets gleichzeitig
  // -------------------------------------------------------------------------
  group('CookingModeIngredientsList – Doppel-Tap add_alarm', () {
    testWidgets(
      'Bug: Doppel-Tap öffnet nicht zwei Timer-Picker gleichzeitig',
      (tester) async {
        await tester.pumpWidget(
          _wrap(ShowRecipeCookingMode(
            recipe: _normalRecipe,
            scaledSections: [_testSection],
          )),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Zutaten'));
        await tester.pumpAndSettle();

        // Doppel-Tap ohne pumpAndSettle dazwischen
        await tester.tap(find.byIcon(Icons.add_alarm));
        // warnIfMissed: false — nach dem ersten Tap öffnet sich das Sheet und
        // verdeckt das Icon; das Verfehlen beim zweiten Tap ist gewollt.
        await tester.tap(find.byIcon(Icons.add_alarm), warnIfMissed: false);
        await tester.pumpAndSettle();

        // Erwartet: genau ein "Timer einstellen" sichtbar
        expect(find.text('Timer einstellen'), findsOneWidget);
      },
    );
  });
}
