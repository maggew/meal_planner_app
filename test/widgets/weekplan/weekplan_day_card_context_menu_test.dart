import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_day_card.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_clipboard_provider.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockRecipeRepository extends Mock implements RecipeRepository {}

MealPlanEntry _recipeEntry({
  String id = 'e1',
  String recipeId = 'r1',
  MealType mealType = MealType.lunch,
  DateTime? date,
}) =>
    MealPlanEntry(
      id: id,
      groupId: 'g1',
      recipeId: recipeId,
      date: date ?? DateTime(2026, 4, 15),
      mealType: mealType,
    );

MealPlanEntry _freeTextEntry({
  String id = 'e2',
  String customName = 'Pizza vom Italiener',
  MealType mealType = MealType.dinner,
  DateTime? date,
}) =>
    MealPlanEntry(
      id: id,
      groupId: 'g1',
      recipeId: null,
      customName: customName,
      date: date ?? DateTime(2026, 4, 15),
      mealType: mealType,
    );

Widget _buildCard({
  required DateTime date,
  required MealPlanEntry entry,
  String recipeName = 'Spaghetti Bolognese',
}) {
  final repo = _MockRecipeRepository();
  when(() => repo.getRecipeTitle(any()))
      .thenAnswer((_) async => recipeName);
  return ProviderScope(
    overrides: [
      mealPlanStreamProvider(date)
          .overrideWith((ref) => Stream.value([entry])),
      recipeRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(
      home: Scaffold(body: WeekplanDayCard(date: date)),
    ),
  );
}

Future<void> _tapMealRow(WidgetTester tester, String displayName) async {
  // Tap inside the row's text to avoid the trailing X-icon.
  await tester.tap(find.text(displayName));
  await tester.pumpAndSettle();
}

void main() {
  group('WeekplanDayCard context menu (recipe entry)', () {
    testWidgets(
        'tap on recipe meal row shows popup menu with 4 items + divider',
        (tester) async {
      final date = DateTime(2026, 4, 15);
      final entry = _recipeEntry();

      await tester.pumpWidget(_buildCard(date: date, entry: entry));
      // Let recipeNameProvider resolve so the title text is visible.
      await tester.pumpAndSettle();

      await _tapMealRow(tester, 'Spaghetti Bolognese');

      expect(find.text('Rezept bearbeiten'), findsOneWidget);
      expect(find.text('Zum Rezept'), findsOneWidget);
      expect(find.text('Ausschneiden'), findsOneWidget);
      expect(find.text('Kopieren'), findsOneWidget);
      expect(find.byType(PopupMenuDivider), findsOneWidget);
    });
  });

  group('WeekplanDayCard context menu (free-text entry)', () {
    testWidgets(
        'tap on free-text meal row shows popup menu with Bearbeiten (no Zum Rezept)',
        (tester) async {
      final date = DateTime(2026, 4, 15);
      final entry = _freeTextEntry();

      await tester.pumpWidget(_buildCard(date: date, entry: entry));
      await tester.pumpAndSettle();

      await _tapMealRow(tester, 'Pizza vom Italiener');

      expect(find.text('Bearbeiten'), findsOneWidget);
      expect(find.text('Zum Rezept'), findsNothing);
      expect(find.text('Ausschneiden'), findsOneWidget);
      expect(find.text('Kopieren'), findsOneWidget);
    });
  });

  group('WeekplanDayCard clipboard actions', () {
    testWidgets('tap → Kopieren sets clipboard to copied entry',
        (tester) async {
      final date = DateTime(2026, 4, 15);
      final entry = _recipeEntry();
      final repo = _MockRecipeRepository();
      when(() => repo.getRecipeTitle(any()))
          .thenAnswer((_) async => 'Spaghetti Bolognese');

      final container = ProviderContainer(overrides: [
        mealPlanStreamProvider(date)
            .overrideWith((ref) => Stream.value([entry])),
        recipeRepositoryProvider.overrideWithValue(repo),
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

      await _tapMealRow(tester, 'Spaghetti Bolognese');
      await tester.tap(find.text('Kopieren'));
      await tester.pumpAndSettle();

      final clipboard = container.read(mealPlanClipboardProvider);
      expect(clipboard, isNotNull);
      expect(clipboard!.entry.id, 'e1');
      expect(clipboard.isCut, isFalse);
    });

    testWidgets('tap → Ausschneiden sets clipboard with isCut=true',
        (tester) async {
      final date = DateTime(2026, 4, 15);
      final entry = _recipeEntry();
      final repo = _MockRecipeRepository();
      when(() => repo.getRecipeTitle(any()))
          .thenAnswer((_) async => 'Spaghetti Bolognese');

      final container = ProviderContainer(overrides: [
        mealPlanStreamProvider(date)
            .overrideWith((ref) => Stream.value([entry])),
        recipeRepositoryProvider.overrideWithValue(repo),
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

      await _tapMealRow(tester, 'Spaghetti Bolognese');
      await tester.tap(find.text('Ausschneiden'));
      await tester.pumpAndSettle();

      final clipboard = container.read(mealPlanClipboardProvider);
      expect(clipboard, isNotNull);
      expect(clipboard!.isCut, isTrue);
    });
  });

}
