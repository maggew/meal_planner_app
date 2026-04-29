import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/domain/entities/cooking_recipe_entry.dart';
import 'package:meal_planner/presentation/common/cooking_mini_bar.dart';
import 'package:meal_planner/presentation/common/glass_card.dart';
import 'package:meal_planner/services/providers/cooking/active_cooking_session_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _recipeId = 'r1';

CookingRecipeEntry _entry({String id = _recipeId, String name = 'Pasta'}) =>
    CookingRecipeEntry(recipeId: id, recipeName: name);

ActiveTimer _runningTimer({String recipeId = _recipeId}) => ActiveTimer(
      recipeId: recipeId,
      stepIndex: 0,
      label: 'Test Timer',
      totalSeconds: 300,
      savedDurationSeconds: 300,
      endTime: DateTime.now().add(const Duration(seconds: 120)),
      notificationId: 0,
      status: TimerStatus.running,
    );

ActiveTimer _finishedTimer({String recipeId = _recipeId}) => ActiveTimer(
      recipeId: recipeId,
      stepIndex: 0,
      label: 'Test Timer',
      totalSeconds: 300,
      savedDurationSeconds: 300,
      endTime: DateTime.now().subtract(const Duration(seconds: 10)),
      notificationId: 0,
      status: TimerStatus.finished,
    );

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer({
  bool addRecipe = false,
  bool wasInCookingMode = true,
  bool addSecondRecipe = false,
  Map<String, ActiveTimer> timers = const {},
}) {
  final container = ProviderContainer(overrides: [
    activeTimerProvider.overrideWithValue(timers),
    timerTickProvider.overrideWithValue(0),
  ]);
  if (addRecipe) {
    container
        .read(activeCookingSessionProvider.notifier)
        .addRecipe(_entry());
    if (addSecondRecipe) {
      container
          .read(activeCookingSessionProvider.notifier)
          .addRecipe(_entry(id: 'r2', name: 'Pizza'));
    }
    if (!wasInCookingMode) {
      container
          .read(activeCookingSessionProvider.notifier)
          .setWasInCookingMode(false);
    }
  }
  return container;
}

Widget _wrap(ProviderContainer container) => UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(body: Column(children: [CookingMiniBar()])),
      ),
    );

double _miniBarHeight(WidgetTester tester) =>
    tester.getSize(find.byType(SizeTransition).first).height;

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CookingMiniBar', () {
    testWidgets('hidden when wasInCookingMode is false', (tester) async {
      final container = _makeContainer(
        addRecipe: true,
        wasInCookingMode: false,
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      expect(_miniBarHeight(tester), 0.0);
    });

    testWidgets('visible when session active and wasInCookingMode is true',
        (tester) async {
      final container = _makeContainer(addRecipe: true);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      expect(_miniBarHeight(tester), greaterThan(0));
    });

    testWidgets('X button visible for single recipe with no timers',
        (tester) async {
      final container = _makeContainer(addRecipe: true);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('X button hidden when timer is running', (tester) async {
      final container = _makeContainer(
        addRecipe: true,
        timers: {'$_recipeId:0': _runningTimer()},
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('X button hidden when timer is finished (alarm firing)',
        (tester) async {
      final container = _makeContainer(
        addRecipe: true,
        timers: {'$_recipeId:0': _finishedTimer()},
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('X button hidden when two recipes active', (tester) async {
      final container = _makeContainer(
        addRecipe: true,
        addSecondRecipe: true,
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('tapping X clears the session', (tester) async {
      final container = _makeContainer(addRecipe: true);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(
        container.read(activeCookingSessionProvider).isActive,
        isFalse,
      );
    });
  });
}
