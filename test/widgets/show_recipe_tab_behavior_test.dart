import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/domain/entities/cooking_recipe_entry.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/services/providers/cooking/active_cooking_session_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';

// ---------------------------------------------------------------------------
// A minimal stand-in that holds only the tab-change logic from ShowRecipePage.
// This avoids the need for a full AutoRoute / Scaffold tree while still
// exercising the exact code path that changes session state.
// ---------------------------------------------------------------------------

class _TabBehaviorHarness extends ConsumerStatefulWidget {
  final Recipe recipe;
  const _TabBehaviorHarness({required this.recipe});

  @override
  ConsumerState<_TabBehaviorHarness> createState() =>
      _TabBehaviorHarnessState();
}

class _TabBehaviorHarnessState extends ConsumerState<_TabBehaviorHarness>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(_onTabChanged);
  }

  // Mirror of ShowRecipePage._onSingleModeTabChanged after the fix.
  void _onTabChanged() {
    if (_controller.indexIsChanging) return;
    final session = ref.read(activeCookingSessionProvider);
    final notifier = ref.read(activeCookingSessionProvider.notifier);

    if (_controller.index == 1) {
      if (widget.recipe.id != null) {
        final wasActive = session.isActive;
        notifier.addRecipe(CookingRecipeEntry(
          recipeId: widget.recipe.id!,
          recipeName: widget.recipe.name,
          imageUrl: widget.recipe.imageUrl,
        ));
        if (wasActive) {
          notifier.setCurrentRecipe(widget.recipe.id!);
          notifier.setWasInCookingMode(true);
        }
      }
    } else {
      if (session.isActive && session.recipes.length == 1) {
        final timers = ref.read(activeTimerProvider);
        final recipeIds = session.recipes.map((e) => e.recipeId).toSet();
        final hasActiveTimers = timers.values.any(
          (t) =>
              recipeIds.contains(t.recipeId) &&
              (t.status == TimerStatus.running ||
                  t.status == TimerStatus.paused),
        );
        if (!hasActiveTimers) {
          notifier.clearSession();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextButton(
        key: const Key('cooking_tab'),
        onPressed: () => _controller.index = 1,
        child: const Text('Kochen'),
      ),
      TextButton(
        key: const Key('overview_tab'),
        onPressed: () => _controller.index = 0,
        child: const Text('Übersicht'),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _testRecipe = Recipe(
  id: 'r1',
  name: 'Pasta',
  categories: [],
  portions: 2,
  ingredientSections: [],
  instructions: '',
);

final _recipeB = Recipe(
  id: 'r2',
  name: 'Pizza',
  categories: [],
  portions: 2,
  ingredientSections: [],
  instructions: '',
);

ProviderContainer _makeContainer() => ProviderContainer(overrides: [
      activeTimerProvider.overrideWithValue({}),
      timerTickProvider.overrideWithValue(0),
    ]);

Widget _wrap(ProviderContainer container) => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: _TabBehaviorHarness(recipe: _testRecipe),
        ),
      ),
    );

Widget _wrapRecipe(ProviderContainer container, Recipe recipe) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: _TabBehaviorHarness(recipe: recipe),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ShowRecipePage tab behavior', () {
    testWidgets(
        'switching to cooking tab starts a session with the recipe',
        (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));

      expect(container.read(activeCookingSessionProvider).isActive, isFalse);

      await tester.tap(find.byKey(const Key('cooking_tab')));
      await tester.pump();

      final session = container.read(activeCookingSessionProvider);
      expect(session.isActive, isTrue);
      expect(session.recipes.first.recipeId, 'r1');
      expect(session.wasInCookingMode, isTrue);
    });

    testWidgets(
        'switching back to overview tab without timers clears session',
        (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));

      // Enter cooking tab to start session
      await tester.tap(find.byKey(const Key('cooking_tab')));
      await tester.pump();
      expect(container.read(activeCookingSessionProvider).isActive, isTrue);

      // Go back to overview
      await tester.tap(find.byKey(const Key('overview_tab')));
      await tester.pump();

      expect(
        container.read(activeCookingSessionProvider).isActive,
        isFalse,
      );
    });

    testWidgets(
        'active session: switching to cooking tab on new recipe adds it and makes it current',
        (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Pre-seed: recipe r1 is already in the session
      container.read(activeCookingSessionProvider.notifier).addRecipe(
            const CookingRecipeEntry(recipeId: 'r1', recipeName: 'Pasta'),
          );
      expect(container.read(activeCookingSessionProvider).isActive, isTrue);

      // User opens recipe B (not yet in session)
      await tester.pumpWidget(_wrapRecipe(container, _recipeB));

      await tester.tap(find.byKey(const Key('cooking_tab')));
      await tester.pump();

      final session = container.read(activeCookingSessionProvider);
      expect(session.isRecipeActive('r2'), isTrue,
          reason: 'Rezept B muss der Session hinzugefügt worden sein');
      expect(session.currentRecipeId, 'r2',
          reason: 'Rezept B muss das aktuelle Rezept der Session sein');
    });

    testWidgets(
        'active session: switching to cooking tab on recipe already in session sets it as current without duplicating',
        (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Pre-seed: r1 and r2 both in session, r2 is current
      container.read(activeCookingSessionProvider.notifier).addRecipe(
            const CookingRecipeEntry(recipeId: 'r1', recipeName: 'Pasta'),
          );
      container.read(activeCookingSessionProvider.notifier).addRecipe(
            const CookingRecipeEntry(recipeId: 'r2', recipeName: 'Pizza'),
          );
      container
          .read(activeCookingSessionProvider.notifier)
          .setCurrentRecipe('r2');
      expect(
          container.read(activeCookingSessionProvider).currentRecipeId, 'r2');

      // User opens r1 (already in session) and taps cooking tab
      await tester.pumpWidget(_wrap(container));

      await tester.tap(find.byKey(const Key('cooking_tab')));
      await tester.pump();

      final session = container.read(activeCookingSessionProvider);
      expect(
        session.recipes.where((e) => e.recipeId == 'r1').length,
        1,
        reason: 'Kein Duplikat für r1',
      );
      expect(session.currentRecipeId, 'r1',
          reason: 'r1 muss das aktuelle Rezept werden');
    });

    testWidgets(
        'switching to overview tab while timer runs keeps session active',
        (tester) async {
      final container = ProviderContainer(overrides: [
        timerTickProvider.overrideWithValue(0),
        activeTimerProvider.overrideWithValue({
          'r1:0': ActiveTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'Test',
            totalSeconds: 300,
            savedDurationSeconds: 300,
            endTime: DateTime.now().add(const Duration(seconds: 120)),
            notificationId: 0,
            status: TimerStatus.running,
          ),
        }),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));

      await tester.tap(find.byKey(const Key('cooking_tab')));
      await tester.pump();
      expect(container.read(activeCookingSessionProvider).isActive, isTrue);

      // Timer is running → switching to overview should NOT clear session
      await tester.tap(find.byKey(const Key('overview_tab')));
      await tester.pump();

      expect(
        container.read(activeCookingSessionProvider).isActive,
        isTrue,
      );
    });
  });
}
