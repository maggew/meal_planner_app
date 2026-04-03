import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
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
  ingredients: [
    Ingredient(name: 'Nudeln', unit: null, amount: '200'),
    Ingredient(name: 'Zwiebel', unit: null, amount: '1'),
    Ingredient(name: 'Tomaten', unit: null, amount: '400'),
    Ingredient(name: 'Knoblauch', unit: null, amount: '2'),
    Ingredient(name: 'Olivenöl', unit: null, amount: '3'),
  ],
);

final _testRecipe = Recipe(
  id: _recipeId,
  name: 'Spaghetti Bolognese',
  categories: [],
  portions: 2,
  ingredientSections: [_testSection],
  // 3 nummerierte Schritte → TabController.length = 3
  instructions:
      '1. Nudeln in reichlich gesalzenem Wasser al dente kochen.\n'
      '2. Zwiebeln und Knoblauch in Olivenöl anschwitzen, Tomaten dazugeben.\n'
      '3. Nudeln abgießen, mit der Soße vermengen und servieren.',
);

// Minimale Provider-Overrides: kein Supabase, kein NotificationService
// ignore: prefer_typing_uninitialized_variables
get _timerOverrides => [
      recipeTimersProvider(_recipeId).overrideWith((ref) async => {}),
      activeTimerProvider.overrideWith(ActiveTimerNotifier.new),
      timerTickProvider.overrideWith(TimerTick.new),
    ];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Simuliert einen verkleinerten Viewport (~300 dp Höhe), wie wenn die
/// Soft-Keyboard auf einem 390×812-dp-Gerät aufgeht (~500 dp Tastatur).
void _simulateKeyboardOpen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 900); // 390×300 @ 3x
  tester.view.devicePixelRatio = 3.0;
}

void _setFullViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2436); // 390×812 @ 3x
  tester.view.devicePixelRatio = 3.0;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // WakelockPlus wird in ShowRecipeCookingMode.initState aufgerufen.
  // Ohne diesen Mock wirft der Test MissingPluginException.
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/wakelock'),
      (call) async => null,
    );
  });

  // -------------------------------------------------------------------------
  // Vollständiges Szenario: ShowRecipeCookingMode
  // Reproduziert exakt den gemeldeten Bug:
  //   1. Zutatenliste ausklappen
  //   2. Timer-Picker über add_alarm öffnen
  //   3. Tastatur erscheint → Viewport schrumpft
  // -------------------------------------------------------------------------
  group('ShowRecipeCookingMode', () {
    testWidgets(
      'Bug: kein RenderFlex-Overflow bei ausgeklappter Zutatenliste '
      '+ Timer-Picker + Tastatur-Simulation',
      (tester) async {
        addTearDown(tester.view.reset);
        _setFullViewport(tester);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _timerOverrides,
            child: MaterialApp(
              home: Scaffold(
                body: ShowRecipeCookingMode(
                  recipe: _testRecipe,
                  scaledSections: [_testSection],
                  currentPortions: 4,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Schritt 1: Zutatenliste ausklappen
        await tester.tap(find.text('Zutaten'));
        await tester.pumpAndSettle();

        // Schritt 2: Timer-Picker öffnen (add_alarm Icon links im Toggle-Button)
        await tester.tap(find.byIcon(Icons.add_alarm));
        await tester.pumpAndSettle();

        // Schritt 3: Tastatur erscheint → Viewport verkleinern
        _simulateKeyboardOpen(tester);
        await tester.pump();

        // Kein RenderFlex-Overflow erwartet
        expect(tester.takeException(), isNull);
      },
    );
  });
}
