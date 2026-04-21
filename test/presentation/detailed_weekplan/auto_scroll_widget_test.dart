import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/slot_drag_payload.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/presentation/detailed_weekplan/drag/auto_scroll_while_dragging.dart';
import 'package:meal_planner/services/providers/meal_plan/slot_drag_provider.dart';

/// Minimal harness: 400px viewport with a draggable source at the top and a
/// long child below. A parent `Listener` flips `isDraggingSlotProvider`
/// while the pointer is down so the auto-scroller's ticker runs, the same
/// way the production weekplan flips it around every slot drag.
Widget _harness({
  required ScrollController controller,
  required ProviderContainer container,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            height: 400,
            width: 300,
            child: AutoScrollWhileDragging(
              controller: controller,
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  children: [
                    LongPressDraggable<SlotDragPayload>(
                      data: SlotDragPayload(
                        date: DateTime(2026, 4, 15),
                        mealType: MealType.lunch,
                        entries: const [],
                      ),
                      onDragStarted: () => container
                          .read(isDraggingSlotProvider.notifier)
                          .value = true,
                      onDragEnd: (_) => container
                          .read(isDraggingSlotProvider.notifier)
                          .value = false,
                      feedback: const SizedBox(width: 50, height: 50),
                      child: Container(
                        key: const ValueKey('source'),
                        width: 100,
                        height: 80,
                        color: const Color(0xFFEF5350),
                      ),
                    ),
                    Container(height: 2000, color: const Color(0xFF42A5F5)),
                  ],
                ),
              ),
            ),
          ),
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

Future<void> _pumpFrames(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets(
    'scrolls downward when drag pointer hovers near the bottom edge',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
          _harness(controller: controller, container: container));
      await tester.pumpAndSettle();

      expect(controller.offset, 0);

      final source = tester.getCenter(find.byKey(const ValueKey('source')));
      final gesture = await _startLongPressDrag(tester, source);

      final viewportBox =
          tester.renderObject<RenderBox>(find.byType(AutoScrollWhileDragging));
      final bottomEdgeGlobal =
          viewportBox.localToGlobal(Offset(150, viewportBox.size.height - 10));

      await gesture.moveTo(bottomEdgeGlobal);
      await tester.pump();
      await _pumpFrames(tester, 10);

      expect(controller.offset, greaterThan(0),
          reason:
              'pointer near the bottom edge should drive a positive scroll delta');

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'scrolls upward when pointer drifts to the top edge after scrolling down',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
          _harness(controller: controller, container: container));
      await tester.pumpAndSettle();

      final source = tester.getCenter(find.byKey(const ValueKey('source')));
      final gesture = await _startLongPressDrag(tester, source);

      final viewportBox =
          tester.renderObject<RenderBox>(find.byType(AutoScrollWhileDragging));
      final bottomEdge =
          viewportBox.localToGlobal(Offset(150, viewportBox.size.height - 10));
      final topEdge = viewportBox.localToGlobal(const Offset(150, 10));

      // First scroll down so there's room to scroll back up.
      await gesture.moveTo(bottomEdge);
      await _pumpFrames(tester, 30);
      final peakOffset = controller.offset;
      expect(peakOffset, greaterThan(50));

      // Now drift to the top edge — velocity should flip sign.
      await gesture.moveTo(topEdge);
      await _pumpFrames(tester, 20);

      expect(controller.offset, lessThan(peakOffset),
          reason:
              'pointer near the top edge should drive a negative scroll delta');

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'scrolls back down after being pinned at the top edge',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
          _harness(controller: controller, container: container));
      await tester.pumpAndSettle();

      final source = tester.getCenter(find.byKey(const ValueKey('source')));
      final gesture = await _startLongPressDrag(tester, source);

      final viewportBox =
          tester.renderObject<RenderBox>(find.byType(AutoScrollWhileDragging));
      final topEdge = viewportBox.localToGlobal(const Offset(150, 10));
      final bottomEdge =
          viewportBox.localToGlobal(Offset(150, viewportBox.size.height - 10));

      // Pin at the top edge (offset is already 0 — this is a no-op scroll
      // but the pointer Y is recorded).
      await gesture.moveTo(topEdge);
      await _pumpFrames(tester, 20);
      expect(controller.offset, 0,
          reason: 'at top edge with offset already 0, nothing should scroll');

      // Now drift to the bottom edge — must recover and scroll down.
      await gesture.moveTo(bottomEdge);
      await _pumpFrames(tester, 20);

      expect(controller.offset, greaterThan(0),
          reason:
              'reversing direction after being pinned at an edge must still scroll');

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'scrolls back down after being pinned at top with nested inner DragTargets',
    (tester) async {
      // Reproduction harness: the real weekplan stacks per-slot DragTargets
      // inside the scrollable. Once the outer auto-scroll viewport clamps at
      // offset 0, reversing direction must still work even while the pointer
      // sits over a nested DragTarget.
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  height: 400,
                  width: 300,
                  child: AutoScrollWhileDragging(
                    controller: controller,
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Column(
                        children: [
                          LongPressDraggable<SlotDragPayload>(
                            data: SlotDragPayload(
                              date: DateTime(2026, 4, 15),
                              mealType: MealType.lunch,
                              entries: const [],
                            ),
                            onDragStarted: () => container
                                .read(isDraggingSlotProvider.notifier)
                                .value = true,
                            onDragEnd: (_) => container
                                .read(isDraggingSlotProvider.notifier)
                                .value = false,
                            feedback: const SizedBox(width: 50, height: 50),
                            child: Container(
                              key: const ValueKey('source'),
                              width: 100,
                              height: 80,
                              color: const Color(0xFFEF5350),
                            ),
                          ),
                          // A column of 10 nested DragTargets covering the
                          // rest of the scrollable, each accepting drops.
                          for (var i = 0; i < 10; i++)
                            DragTarget<SlotDragPayload>(
                              onWillAcceptWithDetails: (_) => true,
                              builder: (_, __, ___) => Container(
                                height: 200,
                                color: i.isEven
                                    ? const Color(0xFF42A5F5)
                                    : const Color(0xFF1E88E5),
                                alignment: Alignment.center,
                                child: Text('slot-$i'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final source = tester.getCenter(find.byKey(const ValueKey('source')));
      final gesture = await _startLongPressDrag(tester, source);

      final viewportBox =
          tester.renderObject<RenderBox>(find.byType(AutoScrollWhileDragging));
      final topEdge = viewportBox.localToGlobal(const Offset(150, 10));
      final bottomEdge =
          viewportBox.localToGlobal(Offset(150, viewportBox.size.height - 10));

      // Scroll down first so we have room to go back up.
      await gesture.moveTo(bottomEdge);
      await _pumpFrames(tester, 40);
      expect(controller.offset, greaterThan(100));

      // Now drag all the way to the top — offset should hit 0.
      await gesture.moveTo(topEdge);
      await _pumpFrames(tester, 80);
      expect(controller.offset, 0,
          reason: 'dragging to top must clamp at minScrollExtent');

      // Now reverse: drag back toward bottom — must resume scrolling down.
      await gesture.moveTo(bottomEdge);
      await _pumpFrames(tester, 40);

      expect(controller.offset, greaterThan(0),
          reason:
              'after pinning at top over a nested DragTarget, reversing '
              'direction must still scroll down');

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'pauses scrolling while a chevron hover is active, even with pointer at edge',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
          _harness(controller: controller, container: container));
      await tester.pumpAndSettle();

      final source = tester.getCenter(find.byKey(const ValueKey('source')));
      final gesture = await _startLongPressDrag(tester, source);

      final viewportBox =
          tester.renderObject<RenderBox>(find.byType(AutoScrollWhileDragging));
      final bottomEdge =
          viewportBox.localToGlobal(Offset(150, viewportBox.size.height - 10));

      // Start scrolling down so we can observe it freeze.
      await gesture.moveTo(bottomEdge);
      await _pumpFrames(tester, 5);
      final offsetBeforePause = controller.offset;
      expect(offsetBeforePause, greaterThan(0));

      // Flip the chevron-hover flag — ticker should treat the drag as paused.
      container.read(isHoveringChevronProvider.notifier).value = true;
      await _pumpFrames(tester, 20);
      expect(controller.offset, offsetBeforePause,
          reason: 'scroll must not advance while a chevron hover is active');

      // Releasing the chevron should resume auto-scroll.
      container.read(isHoveringChevronProvider.notifier).value = false;
      await _pumpFrames(tester, 10);
      expect(controller.offset, greaterThan(offsetBeforePause),
          reason: 'clearing the hover flag must resume auto-scroll');

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'does not scroll while no drag is active, even when pointer is near an edge',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
          _harness(controller: controller, container: container));
      await tester.pumpAndSettle();

      // Hover (no long-press, no active drag): ticker must stay dormant.
      final viewportBox =
          tester.renderObject<RenderBox>(find.byType(AutoScrollWhileDragging));
      final bottomEdge =
          viewportBox.localToGlobal(Offset(150, viewportBox.size.height - 10));
      await tester.createGesture(kind: PointerDeviceKind.mouse).then((g) async {
        await g.addPointer(location: bottomEdge);
        addTearDown(g.removePointer);
        await _pumpFrames(tester, 10);
      });

      expect(controller.offset, 0);
    },
  );
}
