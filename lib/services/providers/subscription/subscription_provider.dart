import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/local_keys.dart';
import 'package:meal_planner/domain/entities/group_subscription.dart';
import 'package:meal_planner/domain/enums/subscription_status.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    final prefs = ref.read(sharedPreferencesProvider);
    final cached = _readCache(prefs, groupId);

    // Kick off background load (no-op if offline).
    _load(groupId);

    if (cached == null) {
      // Cache miss → unknown status; do not show free OR premium.
      return const AsyncValue.loading();
    }

    final now = DateTime.now();
    if (cached.expiresAt != null &&
        cached.expiresAt!.isBefore(now) &&
        !cached.autoRenew) {
      // Locally expired and won't renew → flip to free and persist.
      final downgraded = cached.copyWith(
        status: SubscriptionStatus.free,
        expiresAt: null,
      );
      _writeCache(prefs, downgraded);
      return AsyncValue.data(downgraded);
    }

    return AsyncValue.data(cached);
  }

  Future<void> _load(String groupId) async {
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) return;

    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final subscription = await repo.getSubscription(groupId);
      state = AsyncValue.data(subscription);

      // Always cache the latest known status (free or premium).
      final prefs = ref.read(sharedPreferencesProvider);
      await _writeCache(prefs, subscription);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Call on app resume to refresh subscription status.
  void refresh() => ref.invalidateSelf();

  // --- Cache helpers ---

  static String _cacheKey(String groupId) =>
      '${LocalKeys.subscriptionPrefix}$groupId';

  static GroupSubscription? _readCache(
    SharedPreferences prefs,
    String groupId,
  ) {
    final raw = prefs.getString(_cacheKey(groupId));
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final isPremium = json['isPremium'] as bool? ?? false;
      final expiresAtStr = json['expiresAt'] as String?;
      final autoRenew = json['autoRenew'] as bool? ?? true;
      return GroupSubscription(
        groupId: groupId,
        status:
            isPremium ? SubscriptionStatus.premium : SubscriptionStatus.free,
        expiresAt: expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null,
        autoRenew: autoRenew,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeCache(
    SharedPreferences prefs,
    GroupSubscription sub,
  ) async {
    final payload = jsonEncode({
      'isPremium': sub.isPremium,
      'expiresAt': sub.expiresAt?.toIso8601String(),
      'autoRenew': sub.autoRenew,
    });
    await prefs.setString(_cacheKey(sub.groupId), payload);
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, AsyncValue<GroupSubscription>>(
  SubscriptionNotifier.new,
);

final isPremiumProvider = Provider<bool>((ref) {
  final sub = ref.watch(subscriptionProvider);
  return sub.asData?.value.isPremium ?? false;
});
