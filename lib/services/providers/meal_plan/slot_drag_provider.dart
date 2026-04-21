import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'slot_drag_provider.g.dart';

/// True while a meal-slot drag gesture is in progress. Widgets read this to
/// expand empty-day compact buttons into full drop targets and to apply the
/// subtle drop-zone outline across the weekplan.
@Riverpod(keepAlive: true)
class IsDraggingSlot extends _$IsDraggingSlot {
  @override
  bool build() => false;

  set value(bool v) => state = v;
}

/// True while the drag pointer sits on one of the week-strip chevrons. The
/// auto-scroller reads it so the viewport stays still during a dwell —
/// otherwise the stale pointer position (pinned near the top edge) would
/// keep advancing the scroll and hide the week change from the user.
@Riverpod(keepAlive: true)
class IsHoveringChevron extends _$IsHoveringChevron {
  @override
  bool build() => false;

  set value(bool v) => state = v;
}
