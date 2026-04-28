import 'package:flutter/foundation.dart';

/// Declares which sync feature a page owns.
///
/// Pass an instance to [SyncPollingMixin.syncFeature].
sealed class SyncFeature {
  const SyncFeature();
}

final class ShoppingListSync extends SyncFeature {
  const ShoppingListSync();
}

final class MealPlanSync extends SyncFeature {
  const MealPlanSync({required this.monthNotifier});

  /// The currently-visible calendar month. The mixin forwards value changes
  /// to the coordinator via [SyncCoordinator.updateMealPlanMonth] while
  /// polling is active. Owned and disposed by the page's [State].
  final ValueListenable<DateTime> monthNotifier;
}
