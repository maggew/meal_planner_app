import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_ingredients_list.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_instructions.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_page_buttons.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_step_indicator.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_switch_step_page_button.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/timer/cooking_mode_active_timer.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/timer/cooking_mode_idle_timer.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/timer/cooking_mode_timer_duration_picker.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/recipe_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _recipeId = 'recipe1';

ActiveTimer _makeTimer(TimerStatus status) => ActiveTimer(
      recipeId: _recipeId,
      stepIndex: 0,
      label: 'Nudeln kochen',
      totalSeconds: 300,
      savedDurationSeconds: 300,
      endTime: status == TimerStatus.running
          ? DateTime.now().add(const Duration(seconds: 120))
          : null,
      pausedRemainingSeconds: status == TimerStatus.paused ? 120 : null,
      notificationId: 0,
      status: status,
    );

final _savedTimer = RecipeTimer(
  recipeId: _recipeId,
  stepIndex: 0,
  timerName: 'Nudeln kochen',
  durationSeconds: 300,
);

final _testSection = IngredientSection(
  title: '',
  ingredients: [
    Ingredient(name: 'Nudeln', unit: null, amount: '200'),
    Ingredient(name: 'Zwiebel', unit: null, amount: '1'),
  ],
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Stellt einen TabController für Tests bereit, die CookingModePageButtons brauchen.
class _TabWrapper extends StatefulWidget {
  final int length;
  final int initialIndex;
  final Widget Function(TabController) builder;

  const _TabWrapper({
    required this.length,
    this.initialIndex = 0,
    required this.builder,
  });

  @override
  State<_TabWrapper> createState() => _TabWrapperState();
}

class _TabWrapperState extends State<_TabWrapper>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: widget.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_controller);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  group('CookingModeInstructions', () {
    testWidgets('zeigt Instruktionstext an', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CookingModeInstructions(
              instructionStep: 'Wasser zum Kochen bringen.',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Wasser zum Kochen bringen.'), findsOneWidget);
    });

    testWidgets('kein Overflow bei sehr langem Text', (tester) async {
      tester.view.physicalSize = const Size(900, 1200); // 300×400 @3x
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CookingModeInstructions(
              instructionStep:
                  'Dies ist ein sehr langer Instruktionstext, der in einem '
                  'kleinen Viewport möglicherweise ohne korrekte Behandlung '
                  'einen RenderFlex-Overflow verursachen würde, weshalb er '
                  'explizit auf korrekte Darstellung getestet werden muss.',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  // =========================================================================
  group('CookingModeSwitchStepPageButton', () {
    testWidgets('zeigt Label und Icon an', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CookingModeSwitchStepPageButton(
              label: 'Weiter',
              icon: Icons.arrow_forward_outlined,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Weiter'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_outlined), findsOneWidget);
    });

    testWidgets('iconAfter: false → Icon links von Text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CookingModeSwitchStepPageButton(
              label: 'Weiter',
              icon: Icons.arrow_forward_outlined,
              onPressed: () {},
              iconAfter: false,
            ),
          ),
        ),
      );
      await tester.pump();

      final iconDx =
          tester.getCenter(find.byIcon(Icons.arrow_forward_outlined)).dx;
      final textDx = tester.getCenter(find.text('Weiter')).dx;

      expect(iconDx, lessThan(textDx));
    });

    testWidgets('iconAfter: true → Text links von Icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CookingModeSwitchStepPageButton(
              label: 'Zurück',
              icon: Icons.arrow_back_outlined,
              onPressed: () {},
              iconAfter: true,
            ),
          ),
        ),
      );
      await tester.pump();

      final textDx = tester.getCenter(find.text('Zurück')).dx;
      final iconDx =
          tester.getCenter(find.byIcon(Icons.arrow_back_outlined)).dx;

      expect(textDx, lessThan(iconDx));
    });

    testWidgets('onPressed wird aufgerufen', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CookingModeSwitchStepPageButton(
              label: 'Weiter',
              icon: Icons.arrow_forward_outlined,
              onPressed: () => pressed = true,
              iconAfter: true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Weiter'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('minimale Größe 100×60 wird eingehalten', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CookingModeSwitchStepPageButton(
              label: 'X',
              icon: Icons.check,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      final size = tester.getSize(find.byType(ElevatedButton));
      expect(size.width, greaterThanOrEqualTo(100));
      expect(size.height, greaterThanOrEqualTo(60));
    });
  });

  // =========================================================================
  group('CookingModePageButtons', () {
    Widget _buildPageButtons({
      required int length,
      int initialIndex = 0,
      TabController? captureController,
    }) {
      return MaterialApp(
        home: _TabWrapper(
          length: length,
          initialIndex: initialIndex,
          builder: (controller) =>
              Scaffold(body: CookingModePageButtons(tabController: controller)),
        ),
      );
    }

    testWidgets('erster Schritt: kein Zurück-Button sichtbar', (tester) async {
      await tester.pumpWidget(_buildPageButtons(length: 3, initialIndex: 0));
      await tester.pumpAndSettle();

      expect(find.text('Zurück'), findsNothing);
      expect(find.text('Weiter'), findsOneWidget);
    });

    testWidgets('letzter Schritt: zeigt Fertig + Check-Icon', (tester) async {
      await tester.pumpWidget(_buildPageButtons(length: 3, initialIndex: 2));
      await tester.pumpAndSettle();

      expect(find.text('Fertig'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('Weiter'), findsNothing);
    });

    testWidgets('mittlerer Schritt: Zurück und Weiter sichtbar', (tester) async {
      await tester.pumpWidget(_buildPageButtons(length: 3, initialIndex: 1));
      await tester.pumpAndSettle();

      expect(find.text('Zurück'), findsOneWidget);
      expect(find.text('Weiter'), findsOneWidget);
    });

    testWidgets('Weiter erhöht den Tab-Index', (tester) async {
      late TabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: _TabWrapper(
            length: 3,
            initialIndex: 0,
            builder: (c) {
              controller = c;
              return Scaffold(body: CookingModePageButtons(tabController: c));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weiter'));
      await tester.pump();

      expect(controller.index, 1);
    });

    testWidgets('Zurück verringert den Tab-Index', (tester) async {
      late TabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: _TabWrapper(
            length: 3,
            initialIndex: 1,
            builder: (c) {
              controller = c;
              return Scaffold(body: CookingModePageButtons(tabController: c));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Zurück'));
      await tester.pump();

      expect(controller.index, 0);
    });

    testWidgets('Fertig navigiert nicht über letzten Schritt hinaus',
        (tester) async {
      late TabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: _TabWrapper(
            length: 3,
            initialIndex: 2,
            builder: (c) {
              controller = c;
              return Scaffold(body: CookingModePageButtons(tabController: c));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fertig'));
      await tester.pump();

      expect(controller.index, 2);
    });
  });

  // =========================================================================
  group('CookingModeStepIndicator', () {
    testWidgets('zeigt Kreise für alle Schritte (3 Schritte)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CookingModeStepIndicator(totalSteps: 3, currentStep: 0),
          ),
        ),
      );
      await tester.pump();

      // Alle Schritt-Nummern sichtbar (kein Schritt abgeschlossen)
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('abgeschlossene Schritte zeigen Check-Icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            // currentStep=2 → Schritte 0 und 1 abgeschlossen
            body: CookingModeStepIndicator(totalSteps: 3, currentStep: 2),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
      expect(find.text('3'), findsOneWidget); // aktiver Schritt bleibt als Zahl
    });

    testWidgets('onStepTapped liefert korrekten Index', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CookingModeStepIndicator(
              totalSteps: 3,
              currentStep: 0,
              onStepTapped: (i) => tappedIndex = i,
            ),
          ),
        ),
      );
      await tester.pump();

      // Schritt 2 (Index 1) antippen
      await tester.tap(find.text('2'));
      await tester.pump();

      expect(tappedIndex, 1);
    });

    testWidgets('>5 Schritte: Sliding-Window rendert ohne Overflow',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CookingModeStepIndicator(totalSteps: 8, currentStep: 3),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('1 Schritt rendert ohne Fehler (Edge Case)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CookingModeStepIndicator(totalSteps: 1, currentStep: 0),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('1'), findsOneWidget);
    });
  });

  // =========================================================================
  group('CookingModeIngredientsList', () {
    Widget _buildList({
      bool isExpanded = false,
      VoidCallback? onExpandToggle,
      bool hasSavedTimer = false,
    }) {
      return ProviderScope(
        overrides: [
          recipeTimersProvider(_recipeId).overrideWith(
            (ref) async => hasSavedTimer ? {0: _savedTimer} : {},
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CookingModeIngredientsList(
              isExpanded: isExpanded,
              onExpandToggle: onExpandToggle ?? () {},
              ingredientSections: [_testSection],
              recipeId: _recipeId,
              stepNumber: 0,
            ),
          ),
        ),
      );
    }

    testWidgets('zeigt Zutaten-Toggle-Button an', (tester) async {
      await tester.pumpWidget(_buildList());
      await tester.pumpAndSettle();

      expect(find.text('Zutaten'), findsOneWidget);
    });

    testWidgets('onExpandToggle wird bei Tap aufgerufen', (tester) async {
      bool toggled = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeTimersProvider(_recipeId).overrideWith((ref) async => {}),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CookingModeIngredientsList(
                isExpanded: false,
                onExpandToggle: () => toggled = true,
                ingredientSections: [_testSection],
                recipeId: _recipeId,
                stepNumber: 0,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Zutaten'));
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('add_alarm Icon sichtbar wenn kein Timer gespeichert',
        (tester) async {
      await tester.pumpWidget(_buildList(hasSavedTimer: false));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_alarm), findsOneWidget);
    });

    testWidgets('add_alarm Icon nicht sichtbar wenn Timer gespeichert',
        (tester) async {
      await tester.pumpWidget(_buildList(hasSavedTimer: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_alarm), findsNothing);
    });

    testWidgets('add_alarm Tap öffnet Timer-Picker Bottom Sheet',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeTimersProvider(_recipeId).overrideWith((ref) async => {}),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CookingModeIngredientsList(
                isExpanded: false,
                onExpandToggle: () {},
                ingredientSections: [_testSection],
                recipeId: _recipeId,
                stepNumber: 0,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_alarm));
      await tester.pumpAndSettle();

      expect(find.text('Timer einstellen'), findsOneWidget);
    });
  });

  // =========================================================================
  group('CookingModeTimerDurationPicker', () {
    Widget _buildPicker({
      VoidCallback? onStart,
      VoidCallback? onCancel,
      VoidCallback? onSave,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CookingModeTimerDurationPicker(
              labelController: TextEditingController(),
              minutesController: TextEditingController(),
              secondsController: TextEditingController(),
              onStart: onStart ?? () {},
              onCancel: onCancel ?? () {},
              onSave: onSave ?? () {},
            ),
          ),
        ),
      );
    }

    testWidgets('rendert Titel und alle drei Input-Felder', (tester) async {
      await tester.pumpWidget(_buildPicker());
      await tester.pump();

      expect(find.text('Timer einstellen'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('zeigt alle drei Buttons an', (tester) async {
      await tester.pumpWidget(_buildPicker());
      await tester.pump();

      expect(find.text('Abbrechen'), findsOneWidget);
      expect(find.text('Speichern'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('Abbrechen ruft onCancel auf', (tester) async {
      bool cancelled = false;
      await tester.pumpWidget(_buildPicker(onCancel: () => cancelled = true));
      await tester.pump();

      await tester.tap(find.text('Abbrechen'));
      await tester.pump();

      expect(cancelled, isTrue);
    });

    testWidgets('Speichern ruft onSave auf', (tester) async {
      bool saved = false;
      await tester.pumpWidget(_buildPicker(onSave: () => saved = true));
      await tester.pump();

      await tester.tap(find.text('Speichern'));
      await tester.pump();

      expect(saved, isTrue);
    });

    testWidgets('Start ruft onStart auf', (tester) async {
      bool started = false;
      await tester.pumpWidget(_buildPicker(onStart: () => started = true));
      await tester.pump();

      await tester.tap(find.text('Start'));
      await tester.pump();

      expect(started, isTrue);
    });

    testWidgets('kein Overflow auf schmalem Viewport (320dp)', (tester) async {
      tester.view.physicalSize = const Size(960, 1920); // 320×640 @3x
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_buildPicker());
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  // =========================================================================
  group('CookingModeActiveTimer', () {
    Widget _buildActiveTimer(ActiveTimer timer) {
      return ProviderScope(
        overrides: [
          activeTimerProvider.overrideWith(ActiveTimerNotifier.new),
          timerTickProvider.overrideWith(TimerTick.new),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CookingModeActiveTimer(
              timer: timer,
              timerKey: '$_recipeId:0',
            ),
          ),
        ),
      );
    }

    testWidgets('zeigt Timer-Label an', (tester) async {
      await tester.pumpWidget(_buildActiveTimer(_makeTimer(TimerStatus.running)));
      await tester.pump();

      expect(find.text('Nudeln kochen'), findsOneWidget);
    });

    testWidgets('laufender Timer: Pause- und Stopp-Button sichtbar',
        (tester) async {
      await tester.pumpWidget(_buildActiveTimer(_makeTimer(TimerStatus.running)));
      await tester.pump();

      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Stopp'), findsOneWidget);
      expect(find.text('Weiter'), findsNothing);
    });

    testWidgets('pausierter Timer: Weiter- und Stopp-Button sichtbar',
        (tester) async {
      await tester.pumpWidget(_buildActiveTimer(_makeTimer(TimerStatus.paused)));
      await tester.pump();

      expect(find.text('Weiter'), findsOneWidget);
      expect(find.text('Stopp'), findsOneWidget);
      expect(find.text('Pause'), findsNothing);
    });

    testWidgets('fertiger Timer: Fertig!-Text, Check-Icon und Fertig-Button',
        (tester) async {
      await tester
          .pumpWidget(_buildActiveTimer(_makeTimer(TimerStatus.finished)));
      await tester.pump();

      expect(find.text('Fertig!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Fertig'), findsOneWidget); // Dismiss-Button
      expect(find.text('Stopp'), findsNothing);
    });

    testWidgets('Progress-Bar sichtbar', (tester) async {
      await tester.pumpWidget(_buildActiveTimer(_makeTimer(TimerStatus.running)));
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('kein Overflow bei langem Timer-Label', (tester) async {
      final timer = ActiveTimer(
        recipeId: _recipeId,
        stepIndex: 0,
        label:
            'Sehr langer Timer-Name der potenziell überläuft wenn er nicht korrekt behandelt wird',
        totalSeconds: 300,
        savedDurationSeconds: 300,
        endTime: DateTime.now().add(const Duration(seconds: 120)),
        notificationId: 0,
        status: TimerStatus.running,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeTimerProvider.overrideWith(ActiveTimerNotifier.new),
            timerTickProvider.overrideWith(TimerTick.new),
          ],
          child: MaterialApp(
            home: Scaffold(body: CookingModeActiveTimer(timer: timer, timerKey: '$_recipeId:0')),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  // =========================================================================
  group('CookingModeIdleTimer', () {
    testWidgets(
        'kein gespeicherter Timer → nichts gerendert',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CookingModeIdleTimer(
                recipeId: _recipeId,
                stepIndex: 0,
                saved: null,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
      expect(find.text('Timer einstellen'), findsNothing);
    });

    testWidgets('gespeicherter Timer: Play-, Edit-, Delete-Buttons sichtbar',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeTimerProvider.overrideWith(ActiveTimerNotifier.new),
            timerTickProvider.overrideWith(TimerTick.new),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CookingModeIdleTimer(
                recipeId: _recipeId,
                stepIndex: 0,
                saved: _savedTimer,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('gespeicherter Timer: Name und Dauer sichtbar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeTimerProvider.overrideWith(ActiveTimerNotifier.new),
            timerTickProvider.overrideWith(TimerTick.new),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CookingModeIdleTimer(
                recipeId: _recipeId,
                stepIndex: 0,
                saved: _savedTimer, // name: 'Nudeln kochen', duration: 300s
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Nudeln kochen'), findsOneWidget);
      expect(find.text('05:00'), findsOneWidget); // 300s formatiert
    });

    testWidgets('Edit-Button öffnet Timer-Picker als Bottom Sheet',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeTimerProvider.overrideWith(ActiveTimerNotifier.new),
            timerTickProvider.overrideWith(TimerTick.new),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CookingModeIdleTimer(
                recipeId: _recipeId,
                stepIndex: 0,
                saved: _savedTimer,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Timer einstellen'), findsNothing);

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Timer einstellen'), findsOneWidget);
    });
  });
}
