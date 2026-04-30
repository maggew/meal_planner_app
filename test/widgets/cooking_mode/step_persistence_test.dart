import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/cooking_recipe_entry.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_cooking_mode.dart';
import 'package:meal_planner/services/providers/cooking/active_cooking_session_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/recipe_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _recipeId = 'recipe-step-persist';

final _threeStepRecipe = Recipe(
  id: _recipeId,
  name: 'Test Rezept',
  categories: [],
  portions: 2,
  ingredientSections: [
    IngredientSection(
      title: '',
      ingredients: [Ingredient(name: 'Nudeln', unit: null, amount: '200')],
    ),
  ],
  instructions: '1. Nudeln kochen.\n2. Soße machen.\n3. Servieren.',
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer({int sessionStep = 0}) {
  final container = ProviderContainer(overrides: [
    recipeTimersProvider(_recipeId).overrideWith((ref) async => {}),
    activeTimerProvider.overrideWith(ActiveTimerNotifier.new),
    timerTickProvider.overrideWith(TimerTick.new),
  ]);
  container.read(activeCookingSessionProvider.notifier).addRecipe(
        CookingRecipeEntry(
          recipeId: _recipeId,
          recipeName: 'Test Rezept',
          currentStep: sessionStep,
        ),
      );
  return container;
}

Widget _buildWidget(ProviderContainer container, {int? initialStep}) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: ShowRecipeCookingMode(
            recipe: _threeStepRecipe,
            scaledSections: _threeStepRecipe.ingredientSections,
            currentPortions: 2,
            initialStep: initialStep,
          ),
        ),
      ),
    );

int _currentStep(ProviderContainer container) => container
    .read(activeCookingSessionProvider)
    .recipes
    .firstWhere((e) => e.recipeId == _recipeId)
    .currentStep;

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/wakelock'),
      (_) async => null,
    );
  });

  group('ShowRecipeCookingMode – step persistence', () {
    // -------------------------------------------------------------------------
    // Tracer bullet: tapping Weiter once persists step 1 to session.
    // Fails RED because ShowRecipeCookingMode never calls setCurrentStep.
    // -------------------------------------------------------------------------
    testWidgets('tapping Weiter updates currentStep in session', (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildWidget(container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();

      expect(_currentStep(container), 1);
    });

    testWidgets('tapping Weiter twice sets currentStep to 2', (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildWidget(container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();

      expect(_currentStep(container), 2);
    });

    // Zurück navigation — starts at last step (index 2) and goes back.
    testWidgets('tapping Zurück from step 2 sets currentStep to 1', (tester) async {
      final container = _makeContainer(sessionStep: 2);
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildWidget(container, initialStep: 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Zurück'));
      await tester.pumpAndSettle();

      expect(_currentStep(container), 1);
    });
  });
}
