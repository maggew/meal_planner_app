import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/local_keys.dart';
import 'package:meal_planner/domain/entities/group_subscription.dart';
import 'package:meal_planner/domain/enums/subscription_status.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/shared_preferences_provider.dart';

class SubscriptionNotifier extends Notifier<AsyncValue<GroupSubscription>> {
  @override
  AsyncValue<GroupSubscription> build() {
    final groupId = ref.watch(sessionProvider.select((s) => s.groupId));
    if (groupId == null || groupId.isEmpty) {
      return AsyncValue.data(GroupSubscription(
        groupId: '',
        status: SubscriptionStatus.free,
      ));
    }

    _load(groupId);

    // Use cached premium status while Supabase loads.
    final prefs = ref.read(sharedPreferencesProvider);
    final cached = prefs.getBool('${LocalKeys.premiumPrefix}$groupId') ?? false;
    return AsyncValue.data(GroupSubscription(
      groupId: groupId,
      status: cached ? SubscriptionStatus.premium : SubscriptionStatus.free,
    ));
  }

  Future<void> _load(String groupId) async {
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) return;

    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final subscription = await repo.getSubscription(groupId);
      state = AsyncValue.data(subscription);

      // Cache premium status locally for next app start.
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(
        '${LocalKeys.premiumPrefix}$groupId',
        subscription.isPremium,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Call on app resume to refresh subscription status.
  void refresh() => ref.invalidateSelf();
}

final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, AsyncValue<GroupSubscription>>(
  SubscriptionNotifier.new,
);

final isPremiumProvider = Provider<bool>((ref) {
  final sub = ref.watch(subscriptionProvider);
  return sub.asData?.value.isPremium ?? false;
});
