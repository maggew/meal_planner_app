import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/slot_drag_payload.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_week_strip.dart';
import 'package:meal_planner/services/providers/meal_plan/slot_drag_provider.dart';

/// Harness: the strip sits at the top with a `LongPressDraggable` source
/// below it, so a drag gesture can actually start and travel up over the
/// chevrons. Navigation callbacks push strings into [events] so tests can
/// assert how often and in which order they fired.
Widget _harness({
  required DateTime weekStart,
  required List<String> events,
}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            WeekplanWeekStrip(
              weekStart: weekStart,
              onPreviousWeek: () => events.add('prev'),
              onNextWeek: () => events.add('next'),
            ),
            LongPressDraggable<SlotDragPayload>(
              data: SlotDragPayload(
                date: weekStart.add(const Duration(days: 2)),
                mealType: MealType.lunch,
                entries: const [],
              ),
              feedback: const SizedBox(width: 50, height: 50),
              child: Container(
                key: const ValueKey('drag-source'),
                width: 120,
                height: 80,
                color: const Color(0xFFEF5350),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<TestGesture> _startLongPressDrag(
    WidgetTester tester, Offset at) async {
  final gesture = await tester.startGesture(at);
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
  return gesture;
}

void main() {
  testWidgets(
    'hovering drag over next chevron for 1s calls onNextWeek once',
    (tester) async {
      final events = <String>[];
      await tester.pumpWidget(_harness(
        weekStart: DateTime(2026, 4, 13),
        events: events,
      ));
      await tester.pumpAndSettle();

      final sourceCenter =
          tester.getCenter(find.byKey(const ValueKey('drag-source')));
      final gesture = await _startLongPressDrag(tester, sourceCenter);

      final nextChevron =
          tester.getCenter(find.widgetWithIcon(IconButton, Icons.chevron_right));
      await gesture.moveTo(nextChevron);

      await tester.pump(const Duration(milliseconds: 900));
      expect(events, isEmpty, reason: 'must wait the full dwell before firing');

      await tester.pump(const Duration(milliseconds: 200));
      expect(events, ['next'], reason: '1s dwell should fire exactly once');

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'continuous hover over next chevron fires onNextWeek repeatedly every ~1s',
    (tester) async {
      final events = <String>[];
      await tester.pumpWidget(_harness(
        weekStart: DateTime(2026, 4, 13),
        events: events,
      ));
      await tester.pumpAndSettle();

      final sourceCenter =
          tester.getCenter(find.byKey(const ValueKey('drag-source')));
      final gesture = await _startLongPressDrag(tester, sourceCenter);

      final nextChevron =
          tester.getCenter(find.widgetWithIcon(IconButton, Icons.chevron_right));
      await gesture.moveTo(nextChevron);

      await tester.pump(const Duration(milliseconds: 1100));
      expect(events, ['next']);

      await tester.pump(const Duration(milliseconds: 1100));
      expect(events, ['next', 'next'],
          reason: 'continued hover should repeat the navigation');

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'brief hover under 1s then leaving does NOT call onNextWeek',
    (tester) async {
      final events = <String>[];
      await tester.pumpWidget(_harness(
        weekStart: DateTime(2026, 4, 13),
        events: events,
      ));
      await tester.pumpAndSettle();

      final sourceCenter =
          tester.getCenter(find.byKey(const ValueKey('drag-source')));
      final gesture = await _startLongPressDrag(tester, sourceCenter);

      final nextChevron =
          tester.getCenter(find.widgetWithIcon(IconButton, Icons.chevron_right));
      await gesture.moveTo(nextChevron);
      await tester.pump(const Duration(milliseconds: 400));

      // Drift back to the source — dwell must be cancelled.
      await gesture.moveTo(sourceCenter);
      await tester.pump(const Duration(milliseconds: 1500));

      expect(events, isEmpty,
          reason: 'leaving before 1s must cancel the dwell timer');

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'leaving and re-entering resets the dwell timer',
    (tester) async {
      final events = <String>[];
      await tester.pumpWidget(_harness(
        weekStart: DateTime(2026, 4, 13),
        events: events,
      ));
      await tester.pumpAndSettle();

      final sourceCenter =
          tester.getCenter(find.byKey(const ValueKey('drag-source')));
      final gesture = await _startLongPressDrag(tester, sourceCenter);

      final nextChevron =
          tester.getCenter(find.widgetWithIcon(IconButton, Icons.chevron_right));

      // 600ms on chevron, then leave, then re-enter and wait only 600ms:
      // fire must NOT happen because the timer restarts.
      await gesture.moveTo(nextChevron);
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.moveTo(sourceCenter);
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveTo(nextChevron);
      await tester.pump(const Duration(milliseconds: 600));

      expect(events, isEmpty,
          reason: 're-entry should restart the 1s window from zero');

      // After another ~500ms (total 1.1s since re-entry), it fires.
      await tester.pump(const Duration(milliseconds: 500));
      expect(events, ['next']);

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'hovering drag over previous chevron for 1s calls onPreviousWeek',
    (tester) async {
      final events = <String>[];
      await tester.pumpWidget(_harness(
        weekStart: DateTime(2026, 4, 13),
        events: events,
      ));
      await tester.pumpAndSettle();

      final sourceCenter =
          tester.getCenter(find.byKey(const ValueKey('drag-source')));
      final gesture = await _startLongPressDrag(tester, sourceCenter);

      final prevChevron =
          tester.getCenter(find.widgetWithIcon(IconButton, Icons.chevron_left));
      await gesture.moveTo(prevChevron);
      await tester.pump(const Duration(milliseconds: 1100));

      expect(events, ['prev']);

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'hovering drag over a chevron flips isHoveringChevronProvider and clears on leave',
    (tester) async {
      final events = <String>[];
      // Use our own container so we can read the provider from outside.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WeekplanWeekStrip(
                  weekStart: DateTime(2026, 4, 13),
                  onPreviousWeek: () => events.add('prev'),
                  onNextWeek: () => events.add('next'),
                ),
                LongPressDraggable<SlotDragPayload>(
                  data: SlotDragPayload(
                    date: DateTime(2026, 4, 15),
                    mealType: MealType.lunch,
                    entries: const [],
                  ),
                  feedback: const SizedBox(width: 50, height: 50),
                  child: Container(
                    key: const ValueKey('drag-source'),
                    width: 120,
                    height: 80,
                    color: const Color(0xFFEF5350),
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(container.read(isHoveringChevronProvider), isFalse);

      final sourceCenter =
          tester.getCenter(find.byKey(const ValueKey('drag-source')));
      final gesture = await _startLongPressDrag(tester, sourceCenter);

      final nextChevron =
          tester.getCenter(find.widgetWithIcon(IconButton, Icons.chevron_right));
      await gesture.moveTo(nextChevron);
      await tester.pump(const Duration(milliseconds: 50));

      expect(container.read(isHoveringChevronProvider), isTrue,
          reason: 'chevron must flip the hover flag on enter');

      // Drift back off the chevron — hover flag clears.
      await gesture.moveTo(sourceCenter);
      await tester.pump(const Duration(milliseconds: 50));

      expect(container.read(isHoveringChevronProvider), isFalse,
          reason: 'chevron must clear the hover flag on leave');

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'tapping next chevron without dragging still calls onNextWeek (regression)',
    (tester) async {
      final events = <String>[];
      await tester.pumpWidget(_harness(
        weekStart: DateTime(2026, 4, 13),
        events: events,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(events, ['next']);
    },
  );
}
