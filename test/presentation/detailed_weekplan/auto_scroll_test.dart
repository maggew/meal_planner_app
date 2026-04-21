import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/presentation/detailed_weekplan/drag/auto_scroll.dart';

void main() {
  // Fixed viewport for these tests: 0..600 (y=0 is top, y=600 is bottom).
  // edgeSize: pointer must be within 80px of an edge to trigger scroll.
  // maxSpeed: 8 px per call at the extreme edge.
  const viewportTop = 0.0;
  const viewportBottom = 600.0;
  const edgeSize = 80.0;
  const maxSpeed = 8.0;

  double delta(double pointerY) => computeAutoScrollDelta(
        pointerY: pointerY,
        viewportTop: viewportTop,
        viewportBottom: viewportBottom,
        edgeSize: edgeSize,
        maxSpeed: maxSpeed,
      );

  group('computeAutoScrollDelta', () {
    test('returns 0 when pointer is in the middle of the viewport', () {
      expect(delta(300), 0.0);
    });

    test('returns 0 when pointer is exactly edgeSize away from an edge', () {
      expect(delta(edgeSize), 0.0); // top edge band boundary
      expect(delta(viewportBottom - edgeSize), 0.0); // bottom band boundary
    });

    test('returns -maxSpeed when pointer sits on the top edge', () {
      expect(delta(viewportTop), -maxSpeed);
    });

    test('returns +maxSpeed when pointer sits on the bottom edge', () {
      expect(delta(viewportBottom), maxSpeed);
    });

    test('ramps linearly within the top edge band (upward scroll)', () {
      // Halfway through the band → half max speed, scrolling up (negative).
      expect(delta(edgeSize / 2), closeTo(-maxSpeed / 2, 1e-9));
    });

    test('ramps linearly within the bottom edge band (downward scroll)', () {
      expect(
        delta(viewportBottom - edgeSize / 2),
        closeTo(maxSpeed / 2, 1e-9),
      );
    });

    test('clamps to maxSpeed when pointer overshoots past an edge', () {
      // Drag gestures occasionally report positions slightly outside the
      // viewport. Behaviour should saturate, not extrapolate.
      expect(delta(-50), -maxSpeed);
      expect(delta(viewportBottom + 50), maxSpeed);
    });
  });
}
