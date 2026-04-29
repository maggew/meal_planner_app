import 'package:flutter/foundation.dart';

/// Owns the current week-start date and slide-direction flag.
///
/// Callers invoke [next] / [previous] / [jumpTo] and listen for changes to
/// re-render. Side-effects (sync, scroll-to-today) are the caller's
/// responsibility — they depend on widget lifecycle and are not modelled here.
class WeekNavigationController extends ChangeNotifier {
  WeekNavigationController({required DateTime weekStart})
      : _weekStart = weekStart;

  DateTime _weekStart;
  bool _isForwardSlide = true;

  DateTime get weekStart => _weekStart;

  /// True when the most recent navigation moved forward (next week).
  /// Drives the AnimatedSwitcher slide direction.
  bool get isForwardSlide => _isForwardSlide;

  /// Advances to the next week.
  void next() {
    _weekStart = _weekStart.add(const Duration(days: 7));
    _isForwardSlide = true;
    notifyListeners();
  }

  /// Goes back to the previous week.
  void previous() {
    _weekStart = _weekStart.subtract(const Duration(days: 7));
    _isForwardSlide = false;
    notifyListeners();
  }

  /// Jumps to an arbitrary week start without changing [isForwardSlide].
  void jumpTo(DateTime weekStart) {
    _weekStart = weekStart;
    notifyListeners();
  }
}
