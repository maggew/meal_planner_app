import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/detailed_weekplan/drag/auto_scroll.dart';
import 'package:meal_planner/services/providers/meal_plan/slot_drag_provider.dart';

/// Advances [controller] per frame while a weekplan slot drag is active and
/// the drag pointer sits near the top/bottom edge of this widget's viewport.
///
/// Pointer tracking goes through a translucent `Listener` rather than an
/// observer `DragTarget`: Flutter's DragTarget machinery stops iterating at
/// the first accepting target, so an outer non-accepting DragTarget wrapping
/// inner accepting ones would never see `onMove` once an inner slot was
/// under the pointer. Raw pointer events ignore the gesture arena and keep
/// firing regardless of nested drag targets.
class AutoScrollWhileDragging extends ConsumerStatefulWidget {
  const AutoScrollWhileDragging({
    super.key,
    required this.controller,
    required this.child,
    this.edgeSize = 80,
    this.maxSpeed = 14,
  });

  final ScrollController controller;
  final Widget child;
  final double edgeSize;
  final double maxSpeed;

  @override
  ConsumerState<AutoScrollWhileDragging> createState() =>
      _AutoScrollWhileDraggingState();
}

class _AutoScrollWhileDraggingState
    extends ConsumerState<AutoScrollWhileDragging>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double? _pointerGlobalY;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration _) {
    // A chevron dwell pauses the drag in place: if we kept scrolling, the
    // stale pointer-Y (pinned near the top edge) would quietly shift the
    // viewport and hide the week change behind the header.
    if (ref.read(isHoveringChevronProvider)) return;
    final globalY = _pointerGlobalY;
    if (globalY == null) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final localY = box.globalToLocal(Offset(0, globalY)).dy;
    final delta = computeAutoScrollDelta(
      pointerY: localY,
      viewportTop: 0,
      viewportBottom: box.size.height,
      edgeSize: widget.edgeSize,
      maxSpeed: widget.maxSpeed,
    );
    if (delta == 0) return;
    final ctrl = widget.controller;
    if (!ctrl.hasClients) return;
    final next = (ctrl.offset + delta).clamp(
      ctrl.position.minScrollExtent,
      ctrl.position.maxScrollExtent,
    );
    if (next != ctrl.offset) ctrl.jumpTo(next);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isDraggingSlotProvider, (_, isDragging) {
      if (isDragging && !_ticker.isActive) {
        _ticker.start();
      } else if (!isDragging && _ticker.isActive) {
        _ticker.stop();
        _pointerGlobalY = null;
      }
    });

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: (event) {
        _pointerGlobalY = event.position.dy;
      },
      child: widget.child,
    );
  }
}
