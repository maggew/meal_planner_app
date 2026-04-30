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

// ---------------------------------------------------------------------------
// Mirrors the onRemoveRecipe callback + _recipe/_currentPortions update logic
// from ShowRecipePage, used to verify that _recipe stays in sync with the
// session after a recipe is removed.
// ---------------------------------------------------------------------------

class _RemoveBehaviorHarness extends ConsumerStatefulWidget {
  final Recipe initialRecipe;
  final Map<String, Recipe> loadedRecipes;

  const _RemoveBehaviorHarness({
    required this.initialRecipe,
    required this.loadedRecipes,
  });

  @override
  ConsumerState<_RemoveBehaviorHarness> createState() =>
      _RemoveBehaviorHarnessState();
}

class _RemoveBehaviorHarnessState extends ConsumerState<_RemoveBehaviorHarness>
    with SingleTickerProviderStateMixin {
  late Recipe _currentRecipe;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.initialRecipe;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mirror of ShowRecipePage.onRemoveRecipe — always syncs _currentRecipe to
  // the new session currentRecipeId so isMultiMode stays correct after removal.
  void _onRemoveRecipe() {
    final updated = ref.read(activeCookingSessionProvider);
    final newCurrentId = updated.currentRecipeId;
    if (updated.recipes.isNotEmpty &&
        newCurrentId != null &&
        widget.loadedRecipes.containsKey(newCurrentId)) {
      setState(() => _currentRecipe = widget.loadedRecipes[newCurrentId]!);
      if (updated.recipes.length == 1) {
        _tabController.animateTo(1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeCookingSessionProvider);
    final isMultiMode = session.recipes.length >= 2 &&
        session.isRecipeActive(_currentRecipe.id ?? '');

    return Column(children: [
      Text('currentRecipe:${_currentRecipe.id}',
          key: const Key('current_recipe')),
      Text('isMultiMode:$isMultiMode', key: const Key('is_multi_mode')),
      if (!isMultiMode)
        TextButton(
          key: const Key('cooking_tab'),
          onPressed: () => _tabController.index = 1,
          child: const Text('Kochen'),
        ),
      TextButton(
        key: const Key('trigger_remove'),
        onPressed: () {
          ref
              .read(activeCookingSessionProvider.notifier)
              .removeRecipe(_currentRecipe.id!);
          _onRemoveRecipe();
        },
        child: const Text('Entfernen'),
      ),
    ]);
  }
}

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
    final session = ref.watch(activeCookingSessionProvider);
    // Mirrors ShowRecipePage isMultiMode — cooking tab hidden when in multi-mode.
    // Multi-mode only applies when the current recipe is already part of the session.
    final isMultiMode = session.recipes.length >= 2 &&
        session.isRecipeActive(widget.recipe.id ?? '');
    return Column(children: [
      if (!isMultiMode)
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

final _recipeC = Recipe(
  id: 'r3',
  name: 'Risotto',
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
        'active session (1 recipe): switching to cooking tab on same recipe does not duplicate it',
        (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Pre-seed: only r1 in session (sole recipe)
      container.read(activeCookingSessionProvider.notifier).addRecipe(
            const CookingRecipeEntry(recipeId: 'r1', recipeName: 'Pasta'),
          );
      expect(container.read(activeCookingSessionProvider).isRecipeActive('r1'),
          isTrue);

      // User re-opens r1 (already in session) and taps cooking tab
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
          reason: 'r1 bleibt das aktuelle Rezept');
    });

    testWidgets(
        'active session (2 recipes): switching to cooking tab on new recipe adds it and makes it current',
        (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Pre-seed: session already has 2 recipes
      container.read(activeCookingSessionProvider.notifier).addRecipe(
            const CookingRecipeEntry(recipeId: 'r1', recipeName: 'Pasta'),
          );
      container.read(activeCookingSessionProvider.notifier).addRecipe(
            const CookingRecipeEntry(recipeId: 'r2', recipeName: 'Pizza'),
          );
      expect(
          container.read(activeCookingSessionProvider).recipes.length, 2);

      // User opens a third recipe (not yet in session)
      await tester.pumpWidget(_wrapRecipe(container, _recipeC));

      // Cooking tab must be accessible for a recipe not yet in session
      expect(find.byKey(const Key('cooking_tab')), findsOneWidget,
          reason: 'Kochmodus-Tab muss für ein Rezept außerhalb der Session sichtbar sein');

      await tester.tap(find.byKey(const Key('cooking_tab')));
      await tester.pump();

      final session = container.read(activeCookingSessionProvider);
      expect(session.isRecipeActive('r3'), isTrue,
          reason: 'Rezept C muss der Session hinzugefügt worden sein');
      expect(session.currentRecipeId, 'r3',
          reason: 'Rezept C muss das aktuelle Rezept der Session sein');
    });

    testWidgets(
        'removing current recipe from 3-recipe session keeps multi-mode active for remaining 2',
        (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Pre-seed: 3 recipes, r3 is current (the recipe being viewed)
      container.read(activeCookingSessionProvider.notifier).addRecipe(
            const CookingRecipeEntry(recipeId: 'r1', recipeName: 'Pasta'),
          );
      container.read(activeCookingSessionProvider.notifier).addRecipe(
            const CookingRecipeEntry(recipeId: 'r2', recipeName: 'Pizza'),
          );
      container.read(activeCookingSessionProvider.notifier).addRecipe(
            const CookingRecipeEntry(recipeId: 'r3', recipeName: 'Risotto'),
          );
      container
          .read(activeCookingSessionProvider.notifier)
          .setCurrentRecipe('r3');

      final loadedRecipes = {
        'r1': _testRecipe,
        'r2': _recipeB,
        'r3': _recipeC,
      };

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: _RemoveBehaviorHarness(
              initialRecipe: _recipeC,
              loadedRecipes: loadedRecipes,
            ),
          ),
        ),
      ));
      await tester.pump();

      // Confirm multi-mode before removal
      expect(find.text('isMultiMode:true'), findsOneWidget);

      // Remove r3 (the currently viewed recipe)
      await tester.tap(find.byKey(const Key('trigger_remove')));
      await tester.pump();

      // Session still has r1 + r2 → multi-mode must stay active
      expect(
        container.read(activeCookingSessionProvider).recipes.length,
        2,
      );
      expect(find.text('isMultiMode:true'), findsOneWidget,
          reason: 'Multi-mode muss mit 2 verbleibenden Rezepten aktiv bleiben');
      // _currentRecipe should have switched to the new current (r1)
      expect(find.text('currentRecipe:r1'), findsOneWidget,
          reason: '_currentRecipe muss auf das neue aktuelle Rezept wechseln');
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
