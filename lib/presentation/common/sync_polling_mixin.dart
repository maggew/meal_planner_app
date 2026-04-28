import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/data/sync/sync_coordinator.dart';
import 'package:meal_planner/data/sync/sync_feature.dart';
import 'package:meal_planner/services/providers/sync/sync_providers.dart';

/// Manages sync polling lifecycle for a page inside a tab shell.
///
/// Attach with `with SyncPollingMixin` on [ConsumerState] and implement
/// [syncFeature] and [syncRouteName]. The mixin handles enable/disable calls
/// on [SyncCoordinator] automatically based on tab visibility.
///
/// Note: if [syncCoordinatorProvider] rebuilds mid-session (e.g. group switch),
/// polling pauses until the next tab-change event re-enables it.
mixin SyncPollingMixin<W extends ConsumerStatefulWidget> on ConsumerState<W> {
  SyncFeature get syncFeature;

  /// Route name checked against [TabsRouter.current.name] to detect tab activity.
  /// Use `MyRoute.name` from the generated AutoRoute class.
  String get syncRouteName;

  TabsRouter? _syncTabsRouter;
  bool _syncPollingActive = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = AutoTabsRouter.of(context);
    if (_syncTabsRouter != router) {
      _syncTabsRouter?.removeListener(_onSyncTabChange);
      _syncTabsRouter = router;
      _syncTabsRouter?.addListener(_onSyncTabChange);
      _onSyncTabChange();
    }
  }

  void _onSyncTabChange() {
    final router = _syncTabsRouter;
    if (router == null) return;
    final isActive = router.current.name == syncRouteName;
    if (isActive && !_syncPollingActive) {
      _syncPollingActive = true;
      _enablePolling(ref.read(syncCoordinatorProvider));
    } else if (!isActive && _syncPollingActive) {
      _syncPollingActive = false;
      _disablePolling(ref.read(syncCoordinatorProvider));
    }
  }

  void _enablePolling(SyncCoordinator coordinator) {
    switch (syncFeature) {
      case ShoppingListSync():
        coordinator.enableShoppingListPolling();
      case MealPlanSync(:final monthNotifier):
        coordinator.enableMealPlanPolling(monthNotifier.value);
        monthNotifier.addListener(_onMonthChanged);
    }
  }

  void _disablePolling(SyncCoordinator coordinator) {
    switch (syncFeature) {
      case ShoppingListSync():
        coordinator.disableShoppingListPolling();
      case MealPlanSync(:final monthNotifier):
        monthNotifier.removeListener(_onMonthChanged);
        coordinator.disableMealPlanPolling();
    }
  }

  void _onMonthChanged() {
    if (!_syncPollingActive) return;
    final notifier = (syncFeature as MealPlanSync).monthNotifier;
    ref.read(syncCoordinatorProvider).updateMealPlanMonth(notifier.value);
  }

  @override
  void dispose() {
    _syncTabsRouter?.removeListener(_onSyncTabChange);
    if (_syncPollingActive) {
      _disablePolling(ref.read(syncCoordinatorProvider));
    }
    super.dispose();
  }
}
