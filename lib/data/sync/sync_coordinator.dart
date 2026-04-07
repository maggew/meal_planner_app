import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:meal_planner/data/sync/meal_plan_sync_adapter.dart';
import 'package:meal_planner/data/sync/shopping_list_sync_adapter.dart';
import 'package:meal_planner/data/sync/sync_engine.dart';
import 'package:meal_planner/data/sync/sync_types.dart';

/// Owns *when* sync runs (timers, lifecycle, connectivity, manual triggers).
///
/// The [SyncEngine] is stateless and only knows *how* to sync; the coordinator
/// drives it from every relevant trigger and serializes that into typed
/// per-feature methods so callers don't deal with adapters or scopes.
///
/// Polling cadence:
///   - Shopping list: 5s while a shopping page is open.
///   - Meal plan: 30s while a meal plan page is open, scoped to the
///     currently-visible month.
///
/// Page-open polling is opt-in via `enableShoppingListPolling`/
/// `enableMealPlanPolling` and must be torn down again from the page's
/// `dispose`. The coordinator does not poll while no page is open.
class SyncCoordinator with WidgetsBindingObserver {
  SyncCoordinator({
    required SyncEngine engine,
    required MealPlanSyncAdapter mealPlan,
    required ShoppingListSyncAdapter shopping,
    Stream<List<ConnectivityResult>>? connectivityStream,
  })  : _engine = engine,
        _mealPlan = mealPlan,
        _shopping = shopping,
        _connectivityStream =
            connectivityStream ?? Connectivity().onConnectivityChanged;

  final SyncEngine _engine;
  final MealPlanSyncAdapter _mealPlan;
  final ShoppingListSyncAdapter _shopping;
  final Stream<List<ConnectivityResult>> _connectivityStream;

  static const Duration _shoppingInterval = Duration(seconds: 5);
  static const Duration _mealPlanInterval = Duration(seconds: 30);

  Timer? _shoppingTimer;
  Timer? _mealPlanTimer;
  DateTime? _mealPlanMonth;
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  bool _wasOffline = false;
  bool _started = false;

  // ── Manual entry points ────────────────────────────────────────────────────

  /// Pushes pending and pulls remote for the calendar month containing [month].
  Future<SyncResult> syncMealPlan(DateTime month) {
    return _engine.sync(
      _mealPlan,
      MonthScope(month.year, month.month),
    );
  }

  /// Pushes pending and pulls the full remote shopping list.
  Future<SyncResult> syncShoppingList() {
    return _engine.sync(_shopping, const FullScope());
  }

  /// Convenience trigger fired on app resume / connectivity restore. Runs both
  /// features against [currentMonth] and swallows individual failures so a
  /// broken pull on one feature doesn't block the other.
  Future<void> syncAll(DateTime currentMonth) async {
    await Future.wait([
      syncMealPlan(currentMonth).catchError((_) => _emptyResult()),
      syncShoppingList().catchError((_) => _emptyResult()),
    ]);
  }

  // ── Page-open polling ──────────────────────────────────────────────────────

  void enableShoppingListPolling() {
    if (_shoppingTimer?.isActive ?? false) return;
    // Fire immediately on attach so the page reflects fresh data.
    unawaited(syncShoppingList());
    _shoppingTimer = Timer.periodic(
      _shoppingInterval,
      (_) => unawaited(syncShoppingList()),
    );
  }

  void disableShoppingListPolling() {
    _shoppingTimer?.cancel();
    _shoppingTimer = null;
  }

  void enableMealPlanPolling(DateTime month) {
    _mealPlanMonth = month;
    _mealPlanTimer?.cancel();
    unawaited(syncMealPlan(month));
    _mealPlanTimer = Timer.periodic(
      _mealPlanInterval,
      (_) {
        final m = _mealPlanMonth;
        if (m != null) unawaited(syncMealPlan(m));
      },
    );
  }

  /// Updates the month a meal plan poller targets without restarting the
  /// timer (used when the user pages between months in the calendar).
  void updateMealPlanMonth(DateTime month) {
    _mealPlanMonth = month;
    unawaited(syncMealPlan(month));
  }

  void disableMealPlanPolling() {
    _mealPlanTimer?.cancel();
    _mealPlanTimer = null;
    _mealPlanMonth = null;
  }

  // ── Lifecycle / connectivity ───────────────────────────────────────────────

  /// Wires lifecycle (`WidgetsBinding`) and connectivity listeners. Call once
  /// from app startup. Idempotent.
  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _connSub = _connectivityStream.listen(_onConnectivityChanged);
  }

  /// Tears down listeners and cancels all timers.
  void stop() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
    _connSub?.cancel();
    _connSub = null;
    disableShoppingListPolling();
    disableMealPlanPolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // Only sync features whose pages are currently open. If a page is open it
    // already has a timer, but firing immediately on resume avoids waiting up
    // to a full interval.
    if (_shoppingTimer != null) unawaited(syncShoppingList());
    final m = _mealPlanMonth;
    if (m != null) unawaited(syncMealPlan(m));
  }

  void _onConnectivityChanged(List<ConnectivityResult> result) {
    final isOnline = !result.contains(ConnectivityResult.none);
    if (isOnline && _wasOffline) {
      // Connectivity restored — flush pending changes for any open feature.
      if (_shoppingTimer != null) unawaited(syncShoppingList());
      final m = _mealPlanMonth;
      if (m != null) unawaited(syncMealPlan(m));
    }
    _wasOffline = !isOnline;
  }

  static SyncResult _emptyResult() => SyncResult(
        pushed: 0,
        pulled: 0,
        failed: 0,
        errors: const [],
        fatalError: null,
        ranAt: DateTime.now(),
      );
}
