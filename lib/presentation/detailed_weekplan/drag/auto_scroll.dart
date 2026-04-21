/// Returns how many pixels to advance the weekplan scroll controller this
/// tick, based on how close the drag pointer is to the top or bottom edge of
/// the scroll viewport.
///
/// Conventions:
/// - `pointerY`, `viewportTop`, `viewportBottom` are in the same coordinate
///   space (global, local — doesn't matter, as long as they agree).
/// - Positive return value: scroll down (reveal content below).
/// - Negative return value: scroll up (reveal content above).
/// - Zero: pointer is outside either edge band, no auto-scroll.
///
/// Inside an edge band, the speed ramps linearly from 0 at the inner
/// boundary to [maxSpeed] at the outer edge. Pointer positions past an
/// edge saturate at [maxSpeed] rather than extrapolating.
double computeAutoScrollDelta({
  required double pointerY,
  required double viewportTop,
  required double viewportBottom,
  required double edgeSize,
  required double maxSpeed,
}) {
  final topBand = viewportTop + edgeSize;
  if (pointerY < topBand) {
    final distance = pointerY - viewportTop;
    final ratio = (distance / edgeSize).clamp(0.0, 1.0);
    return -(1.0 - ratio) * maxSpeed;
  }

  final bottomBand = viewportBottom - edgeSize;
  if (pointerY > bottomBand) {
    final distance = viewportBottom - pointerY;
    final ratio = (distance / edgeSize).clamp(0.0, 1.0);
    return (1.0 - ratio) * maxSpeed;
  }

  return 0.0;
}
