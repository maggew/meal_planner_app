import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/entities/slot_drag_payload.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/domain/repositories/meal_plan_repository.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_day_card.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';
import 'package:meal_planner/services/providers/meal_plan/slot_drag_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealPlanRepository extends Mock implements MealPlanRepository {}

class _MockRecipeRepository extends Mock implements RecipeRepository {}

MealPlanEntry _entry({
  String id = 'e1',
  String recipeId = 'r1',
  required MealType mealType,
  required DateTime date,
}) =>
    MealPlanEntry(
      id: id,
      groupId: 'g1',
      recipeId: recipeId,
      date: date,
      mealType: mealType,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026, 1, 1));
    registerFallbackValue(MealType.lunch);
  });

  group('Empty-day expansion during drag', () {
    testWidgets(
      'empty day shows three _CompactAddButton IconButtons when no drag is active',
      (tester) async {
        final date = DateTime(2026, 4, 15);

        final container = ProviderContainer(overrides: [
          mealPlanStreamProvider(date)
              .overrideWith((ref) => Stream.value(const [])),
        ]);
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(body: WeekplanDayCard(date: date)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('compact-add-breakfast')),
            findsOneWidget);
        expect(
            find.byKey(const ValueKey('compact-add-lunch')), findsOneWidget);
        expect(
            find.byKey(const ValueKey('compact-add-dinner')), findsOneWidget);
        expect(find.byKey(const ValueKey('empty-slot-breakfast')), findsNothing);
      },
    );

    testWidgets(
      'empty day keeps compact icons during drag (no layout shift)',
      (tester) async {
        final date = DateTime(2026, 4, 15);

        final container = ProviderContainer(overrides: [
          mealPlanStreamProvider(date)
              .overrideWith((ref) => Stream.value(const [])),
        ]);
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(body: WeekplanDayCard(date: date)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final sizeBefore = tester.getSize(find.byType(WeekplanDayCard));

        container.read(isDraggingSlotProvider.notifier).state = true;
        await tester.pumpAndSettle();

        // Compact icons stay put — no expansion into _EmptySlotRows.
        expect(find.byKey(const ValueKey('compact-add-breakfast')),
            findsOneWidget);
        expect(
            find.byKey(const ValueKey('compact-add-lunch')), findsOneWidget);
        expect(
            find.byKey(const ValueKey('compact-add-dinner')), findsOneWidget);
        expect(find.byKey(const ValueKey('empty-slot-breakfast')), findsNothing);
        expect(find.byKey(const ValueKey('empty-slot-lunch')), findsNothing);
        expect(find.byKey(const ValueKey('empty-slot-dinner')), findsNothing);

        final sizeAfter = tester.getSize(find.byType(WeekplanDayCard));
        expect(sizeAfter, sizeBefore,
            reason: 'drag start must not change the card size');
      },
    );

    testWidgets(
      'filled slot is wrapped in LongPressDraggable with SlotDragPayload',
      (tester) async {
        final date = DateTime(2026, 4, 15);
        final entry =
            _entry(id: 'e1', mealType: MealType.lunch, date: date);

        final container = ProviderContainer(overrides: [
          mealPlanStreamProvider(date)
              .overrideWith((ref) => Stream.value([entry])),
        ]);
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(body: WeekplanDayCard(date: date)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final draggables = tester.widgetList<LongPressDraggable<SlotDragPayload>>(
          find.byType(LongPressDraggable<SlotDragPayload>),
        );
        expect(draggables, hasLength(1));

        final payload = draggables.single.data!;
        expect(payload.date, date);
        expect(payload.mealType, MealType.lunch);
        expect(payload.entries.map((e) => e.id), ['e1']);
      },
    );

    testWidgets(
      'filled day that has an empty slot renders _EmptySlotRow for the empty slot regardless of drag state',
      (tester) async {
        final date = DateTime(2026, 4, 15);
        final entry = _entry(mealType: MealType.dinner, date: date);

        final container = ProviderContainer(overrides: [
          mealPlanStreamProvider(date)
              .overrideWith((ref) => Stream.value([entry])),
        ]);
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(body: WeekplanDayCard(date: date)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // breakfast + lunch have no entries → each should render an empty
        // slot row regardless of drag state; dinner has the entry.
        expect(find.byKey(const ValueKey('empty-slot-breakfast')),
            findsOneWidget);
        expect(find.byKey(const ValueKey('empty-slot-lunch')), findsOneWidget);
        expect(find.byKey(const ValueKey('empty-slot-dinner')), findsNothing);
      },
    );
  });

  group('Drop handling', () {
    testWidgets(
      'drop on compact meal icon of another day calls moveEntry for source entries',
      (tester) async {
        final sourceDate = DateTime(2026, 4, 15);
        final targetDate = DateTime(2026, 4, 16);
        final entry =
            _entry(id: 'e1', mealType: MealType.lunch, date: sourceDate);

        final mockRepo = _MockMealPlanRepository();
        final mockRecipeRepo = _MockRecipeRepository();

        when(() => mockRepo.watchEntriesForDate(sourceDate))
            .thenAnswer((_) => Stream.value([entry]));
        when(() => mockRepo.watchEntriesForDate(targetDate))
            .thenAnswer((_) => Stream.value(const []));
        when(() => mockRepo.moveEntry(
              any(),
              date: any(named: 'date'),
              mealType: any(named: 'mealType'),
            )).thenAnswer((_) async => true);
        when(() => mockRecipeRepo.getRecipeTitle(any()))
            .thenAnswer((_) async => 'Spaghetti');

        final container = ProviderContainer(overrides: [
          mealPlanRepositoryProvider.overrideWithValue(mockRepo),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepo),
        ]);
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    WeekplanDayCard(date: sourceDate),
                    WeekplanDayCard(date: targetDate),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Source: filled lunch row in the draggable.
        final sourceText = find.text('Spaghetti');
        final sourceCenter = tester.getCenter(sourceText);

        final gesture = await tester.startGesture(sourceCenter);
        // Long-press delay + a small slack so onDragStarted fires.
        await tester.pump(const Duration(milliseconds: 600));
        // Flush the rebuild triggered by isDraggingSlotProvider = true.
        await tester.pump();

        // Target: the compact lunch icon on the other day — it stays in
        // place during drag and now accepts drops directly.
        final targetFinder = find.byKey(const ValueKey('compact-add-lunch'));
        final targetCenter = tester.getCenter(targetFinder);

        await gesture.moveTo(targetCenter);
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        verify(() => mockRepo.moveEntry(
              'e1',
              date: targetDate,
              mealType: MealType.lunch,
            )).called(1);
      },
    );

    testWidgets(
      'drop back on the source slot is a silent no-op',
      (tester) async {
        final date = DateTime(2026, 4, 15);
        final entry =
            _entry(id: 'e1', mealType: MealType.lunch, date: date);

        final mockRepo = _MockMealPlanRepository();
        final mockRecipeRepo = _MockRecipeRepository();

        when(() => mockRepo.watchEntriesForDate(date))
            .thenAnswer((_) => Stream.value([entry]));
        when(() => mockRepo.moveEntry(
              any(),
              date: any(named: 'date'),
              mealType: any(named: 'mealType'),
            )).thenAnswer((_) async => true);
        when(() => mockRecipeRepo.getRecipeTitle(any()))
            .thenAnswer((_) async => 'Spaghetti');

        final container = ProviderContainer(overrides: [
          mealPlanRepositoryProvider.overrideWithValue(mockRepo),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepo),
        ]);
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(body: WeekplanDayCard(date: date)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final sourceCenter = tester.getCenter(find.text('Spaghetti'));
        final gesture = await tester.startGesture(sourceCenter);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump();
        // Nudge out and back so the drag actually engages before release.
        await gesture.moveBy(const Offset(0, 15));
        await tester.pump();
        await gesture.moveTo(sourceCenter);
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        verifyNever(() => mockRepo.moveEntry(
              any(),
              date: any(named: 'date'),
              mealType: any(named: 'mealType'),
            ));
      },
    );

    testWidgets(
      'drop on occupied target opens dialog with Abbrechen / Hinzufügen / Tauschen',
      (tester) async {
        final sourceDate = DateTime(2026, 4, 15);
        final targetDate = DateTime(2026, 4, 16);
        final sourceEntry =
            _entry(id: 'e1', mealType: MealType.lunch, date: sourceDate);
        final targetEntry = _entry(
            id: 'e2',
            recipeId: 'r2',
            mealType: MealType.lunch,
            date: targetDate);

        final mockRepo = _MockMealPlanRepository();
        final mockRecipeRepo = _MockRecipeRepository();

        when(() => mockRepo.watchEntriesForDate(sourceDate))
            .thenAnswer((_) => Stream.value([sourceEntry]));
        when(() => mockRepo.watchEntriesForDate(targetDate))
            .thenAnswer((_) => Stream.value([targetEntry]));
        when(() => mockRepo.moveEntry(
              any(),
              date: any(named: 'date'),
              mealType: any(named: 'mealType'),
            )).thenAnswer((_) async => true);
        when(() => mockRecipeRepo.getRecipeTitle('r1'))
            .thenAnswer((_) async => 'Spaghetti');
        when(() => mockRecipeRepo.getRecipeTitle('r2'))
            .thenAnswer((_) async => 'Pizza');

        final container = ProviderContainer(overrides: [
          mealPlanRepositoryProvider.overrideWithValue(mockRepo),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepo),
        ]);
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    WeekplanDayCard(date: sourceDate),
                    WeekplanDayCard(date: targetDate),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final sourceCenter = tester.getCenter(find.text('Spaghetti'));
        final targetCenter = tester.getCenter(find.text('Pizza'));

        final gesture = await tester.startGesture(sourceCenter);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump();
        await gesture.moveTo(targetCenter);
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Abbrechen'), findsOneWidget);
        expect(find.text('Hinzufügen'), findsOneWidget);
        expect(find.text('Tauschen'), findsOneWidget);
        verifyNever(() => mockRepo.moveEntry(
              any(),
              date: any(named: 'date'),
              mealType: any(named: 'mealType'),
            ));
      },
    );

    testWidgets(
      'Tauschen swaps source and target entries between their slots',
      (tester) async {
        final sourceDate = DateTime(2026, 4, 15);
        final targetDate = DateTime(2026, 4, 16);
        final sourceEntry =
            _entry(id: 'e1', mealType: MealType.lunch, date: sourceDate);
        final targetEntry = _entry(
            id: 'e2',
            recipeId: 'r2',
            mealType: MealType.dinner,
            date: targetDate);

        final mockRepo = _MockMealPlanRepository();
        final mockRecipeRepo = _MockRecipeRepository();

        when(() => mockRepo.watchEntriesForDate(sourceDate))
            .thenAnswer((_) => Stream.value([sourceEntry]));
        when(() => mockRepo.watchEntriesForDate(targetDate))
            .thenAnswer((_) => Stream.value([targetEntry]));
        when(() => mockRepo.moveEntry(
              any(),
              date: any(named: 'date'),
              mealType: any(named: 'mealType'),
            )).thenAnswer((_) async => true);
        when(() => mockRecipeRepo.getRecipeTitle('r1'))
            .thenAnswer((_) async => 'Spaghetti');
        when(() => mockRecipeRepo.getRecipeTitle('r2'))
            .thenAnswer((_) async => 'Pizza');

        final container = ProviderContainer(overrides: [
          mealPlanRepositoryProvider.overrideWithValue(mockRepo),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepo),
        ]);
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    WeekplanDayCard(date: sourceDate),
                    WeekplanDayCard(date: targetDate),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final sourceCenter = tester.getCenter(find.text('Spaghetti'));
        final targetCenter = tester.getCenter(find.text('Pizza'));

        final gesture = await tester.startGesture(sourceCenter);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump();
        await gesture.moveTo(targetCenter);
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tauschen'));
        await tester.pumpAndSettle();

        verify(() => mockRepo.moveEntry(
              'e1',
              date: targetDate,
              mealType: MealType.dinner,
            )).called(1);
        verify(() => mockRepo.moveEntry(
              'e2',
              date: sourceDate,
              mealType: MealType.lunch,
            )).called(1);
      },
    );

    testWidgets(
      'Hinzufügen moves source entries but leaves target entries in place',
      (tester) async {
        final sourceDate = DateTime(2026, 4, 15);
        final targetDate = DateTime(2026, 4, 16);
        final sourceEntry =
            _entry(id: 'e1', mealType: MealType.lunch, date: sourceDate);
        final targetEntry = _entry(
            id: 'e2',
            recipeId: 'r2',
            mealType: MealType.lunch,
            date: targetDate);

        final mockRepo = _MockMealPlanRepository();
        final mockRecipeRepo = _MockRecipeRepository();

        when(() => mockRepo.watchEntriesForDate(sourceDate))
            .thenAnswer((_) => Stream.value([sourceEntry]));
        when(() => mockRepo.watchEntriesForDate(targetDate))
            .thenAnswer((_) => Stream.value([targetEntry]));
        when(() => mockRepo.moveEntry(
              any(),
              date: any(named: 'date'),
              mealType: any(named: 'mealType'),
            )).thenAnswer((_) async => true);
        when(() => mockRecipeRepo.getRecipeTitle('r1'))
            .thenAnswer((_) async => 'Spaghetti');
        when(() => mockRecipeRepo.getRecipeTitle('r2'))
            .thenAnswer((_) async => 'Pizza');

        final container = ProviderContainer(overrides: [
          mealPlanRepositoryProvider.overrideWithValue(mockRepo),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepo),
        ]);
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    WeekplanDayCard(date: sourceDate),
                    WeekplanDayCard(date: targetDate),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final sourceCenter = tester.getCenter(find.text('Spaghetti'));
        final targetCenter = tester.getCenter(find.text('Pizza'));

        final gesture = await tester.startGesture(sourceCenter);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump();
        await gesture.moveTo(targetCenter);
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Hinzufügen'));
        await tester.pumpAndSettle();

        verify(() => mockRepo.moveEntry(
              'e1',
              date: targetDate,
              mealType: MealType.lunch,
            )).called(1);
        verifyNever(() => mockRepo.moveEntry(
              'e2',
              date: any(named: 'date'),
              mealType: any(named: 'mealType'),
            ));
      },
    );

    testWidgets(
      'Abbrechen dismisses dialog without calling moveEntry',
      (tester) async {
        final sourceDate = DateTime(2026, 4, 15);
        final targetDate = DateTime(2026, 4, 16);
        final sourceEntry =
            _entry(id: 'e1', mealType: MealType.lunch, date: sourceDate);
        final targetEntry = _entry(
            id: 'e2',
            recipeId: 'r2',
            mealType: MealType.lunch,
            date: targetDate);

        final mockRepo = _MockMealPlanRepository();
        final mockRecipeRepo = _MockRecipeRepository();

        when(() => mockRepo.watchEntriesForDate(sourceDate))
            .thenAnswer((_) => Stream.value([sourceEntry]));
        when(() => mockRepo.watchEntriesForDate(targetDate))
            .thenAnswer((_) => Stream.value([targetEntry]));
        when(() => mockRepo.moveEntry(
              any(),
              date: any(named: 'date'),
              mealType: any(named: 'mealType'),
            )).thenAnswer((_) async => true);
        when(() => mockRecipeRepo.getRecipeTitle('r1'))
            .thenAnswer((_) async => 'Spaghetti');
        when(() => mockRecipeRepo.getRecipeTitle('r2'))
            .thenAnswer((_) async => 'Pizza');

        final container = ProviderContainer(overrides: [
          mealPlanRepositoryProvider.overrideWithValue(mockRepo),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepo),
        ]);
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    WeekplanDayCard(date: sourceDate),
                    WeekplanDayCard(date: targetDate),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final sourceCenter = tester.getCenter(find.text('Spaghetti'));
        final targetCenter = tester.getCenter(find.text('Pizza'));

        final gesture = await tester.startGesture(sourceCenter);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump();
        await gesture.moveTo(targetCenter);
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Abbrechen'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        verifyNever(() => mockRepo.moveEntry(
              any(),
              date: any(named: 'date'),
              mealType: any(named: 'mealType'),
            ));
      },
    );

    testWidgets(
      'conflict (moveEntry returns false) surfaces a snackbar',
      (tester) async {
        final sourceDate = DateTime(2026, 4, 15);
        final targetDate = DateTime(2026, 4, 16);
        final entry =
            _entry(id: 'e1', mealType: MealType.lunch, date: sourceDate);

        final mockRepo = _MockMealPlanRepository();
        final mockRecipeRepo = _MockRecipeRepository();

        when(() => mockRepo.watchEntriesForDate(sourceDate))
            .thenAnswer((_) => Stream.value([entry]));
        when(() => mockRepo.watchEntriesForDate(targetDate))
            .thenAnswer((_) => Stream.value(const []));
        when(() => mockRepo.moveEntry(
              any(),
              date: any(named: 'date'),
              mealType: any(named: 'mealType'),
            )).thenAnswer((_) async => false);
        when(() => mockRecipeRepo.getRecipeTitle(any()))
            .thenAnswer((_) async => 'Spaghetti');

        final container = ProviderContainer(overrides: [
          mealPlanRepositoryProvider.overrideWithValue(mockRepo),
          recipeRepositoryProvider.overrideWithValue(mockRecipeRepo),
        ]);
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    WeekplanDayCard(date: sourceDate),
                    WeekplanDayCard(date: targetDate),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final sourceCenter = tester.getCenter(find.text('Spaghetti'));
        final gesture = await tester.startGesture(sourceCenter);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump();
        final targetCenter =
            tester.getCenter(find.byKey(const ValueKey('compact-add-lunch')));
        await gesture.moveTo(targetCenter);
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        expect(
          find.text('Eintrag wurde inzwischen geändert. Bitte erneut versuchen.'),
          findsOneWidget,
        );
      },
    );
  });
}
