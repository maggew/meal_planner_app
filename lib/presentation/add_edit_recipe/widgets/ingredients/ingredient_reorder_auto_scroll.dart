import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:meal_planner/presentation/detailed_weekplan/drag/auto_scroll.dart';

/// Wraps its [builder] child with auto-scroll behaviour for the outer
/// [scrollController] while an ingredient reorder drag is active.
///
/// The [builder] receives a [ValueNotifier<bool>] that the reorderable list
/// sets to `true` on drag start and `false` on drag end.  A [Listener] tracks
/// the pointer position, and a [Ticker] advances the scroll per frame whenever
/// the pointer sits inside the top/bottom edge band.
class IngredientReorderAutoScroll extends StatefulWidget {
  const IngredientReorderAutoScroll({
    super.key,
    required this.scrollController,
    required this.builder,
    this.scrollLimitKey,
    this.scrollLimitPadding = 50.0,
    this.edgeSize = 80.0,
    this.maxSpeed = 14.0,
  });

  final ScrollController scrollController;
  final Widget Function(ValueNotifier<bool> isDragging) builder;
  /// When set, downward auto-scroll stops once the bottom of this widget
  /// + [scrollLimitPadding] reaches the viewport bottom.
  final GlobalKey? scrollLimitKey;
  final double scrollLimitPadding;
  final double edgeSize;
  final double maxSpeed;

  @override
  State<IngredientReorderAutoScroll> createState() =>
      _IngredientReorderAutoScrollState();
}

class _IngredientReorderAutoScrollState
    extends State<IngredientReorderAutoScroll>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final ValueNotifier<bool> _isDragging;
  double? _pointerGlobalY;

  @override
  void initState() {
    super.initState();
    _isDragging = ValueNotifier(false);
    _ticker = createTicker(_onTick);
    _isDragging.addListener(_onDragChanged);
  }

  @override
  void dispose() {
    _isDragging.removeListener(_onDragChanged);
    _isDragging.dispose();
    _ticker.dispose();
    super.dispose();
  }

  void _onDragChanged() {
    if (_isDragging.value) {
      if (!_ticker.isActive) _ticker.start();
    } else {
      if (_ticker.isActive) _ticker.stop();
      _pointerGlobalY = null;
    }
  }

  void _onTick(Duration _) {
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
    final ctrl = widget.scrollController;
    if (!ctrl.hasClients) return;

    double minExtent = ctrl.position.minScrollExtent;
    double maxExtent = ctrl.position.maxScrollExtent;

    final limitBox =
        widget.scrollLimitKey?.currentContext?.findRenderObject() as RenderBox?;
    if (limitBox != null) {
      final viewportTopGlobal = box.localToGlobal(Offset.zero).dy;
      final viewportBottomGlobal = box.localToGlobal(Offset(0, box.size.height)).dy;
      if (delta < 0) {
        // Scrolling up: stop when ingredients top − padding reaches viewport top.
        final limitTopGlobal = limitBox.localToGlobal(Offset.zero).dy;
        final customMin = ctrl.offset +
            (limitTopGlobal - viewportTopGlobal) -
            widget.scrollLimitPadding;
        minExtent = customMin.clamp(
          ctrl.position.minScrollExtent,
          ctrl.position.maxScrollExtent,
        );
      } else {
        // Scrolling down: stop when ingredients bottom + padding reaches viewport bottom.
        final limitBottomGlobal =
            limitBox.localToGlobal(Offset(0, limitBox.size.height)).dy;
        final headroom =
            limitBottomGlobal + widget.scrollLimitPadding - viewportBottomGlobal;
        maxExtent = (ctrl.offset + headroom).clamp(
          ctrl.position.minScrollExtent,
          ctrl.position.maxScrollExtent,
        );
      }
    }

    final next = (ctrl.offset + delta).clamp(minExtent, maxExtent);
    if (next != ctrl.offset) ctrl.jumpTo(next);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: (event) {
        if (_isDragging.value) _pointerGlobalY = event.position.dy;
      },
      child: widget.builder(_isDragging),
    );
  }
}
