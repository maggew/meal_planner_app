import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/subscription/subscription_provider.dart';

class SubscriptionRefreshObserver extends WidgetsBindingObserver {
  final WidgetRef ref;
  SubscriptionRefreshObserver(this.ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(subscriptionProvider.notifier).refresh();
    }
  }
}
