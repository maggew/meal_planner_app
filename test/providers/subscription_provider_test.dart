import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/constants/local_keys.dart';
import 'package:meal_planner/domain/entities/group_subscription.dart';
import 'package:meal_planner/domain/enums/subscription_status.dart';
import 'package:meal_planner/domain/repositories/subscription_repository.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/shared_preferences_provider.dart';
import 'package:meal_planner/services/providers/subscription/subscription_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

const _groupId = '00000000-0000-0000-0000-000000000001';

String _cacheKey(String groupId) => '${LocalKeys.subscriptionPrefix}$groupId';

String _cachePayload({
  required bool isPremium,
  DateTime? expiresAt,
  bool autoRenew = true,
}) {
  return jsonEncode({
    'isPremium': isPremium,
    'expiresAt': expiresAt?.toIso8601String(),
    'autoRenew': autoRenew,
  });
}

Future<ProviderContainer> _makeContainer({
  Map<String, Object> initialPrefs = const {},
  bool isOnline = false,
  SubscriptionRepository? repo,
  String? groupId = _groupId,
}) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
    sessionProvider.overrideWithValue(
      SessionState(userId: 'u1', groupId: groupId),
    ),
    isOnlineProvider.overrideWithValue(isOnline),
    if (repo != null) subscriptionRepositoryProvider.overrideWithValue(repo),
  ]);
}

void main() {
  setUpAll(() {
    registerFallbackValue(_groupId);
  });

  group('SubscriptionNotifier.build()', () {
    test('groupId leer → AsyncData(free)', () async {
      final container = await _makeContainer(groupId: null);
      addTearDown(container.dispose);

      final state = container.read(subscriptionProvider);
      expect(state, isA<AsyncData<GroupSubscription>>());
      expect(state.requireValue.isPremium, false);
    });

    test('Cache-Miss → AsyncLoading', () async {
      final container = await _makeContainer();
      addTearDown(container.dispose);

      final state = container.read(subscriptionProvider);
      expect(state, isA<AsyncLoading<GroupSubscription>>());
      expect(container.read(isPremiumProvider), false);
    });

    test('Cache-Hit free → AsyncData(free)', () async {
      final container = await _makeContainer(initialPrefs: {
        _cacheKey(_groupId): _cachePayload(isPremium: false),
      });
      addTearDown(container.dispose);

      final state = container.read(subscriptionProvider);
      expect(state.requireValue.isPremium, false);
      expect(container.read(isPremiumProvider), false);
    });

    test('Cache-Hit premium → AsyncData(premium)', () async {
      final future = DateTime.now().add(const Duration(days: 30));
      final container = await _makeContainer(initialPrefs: {
        _cacheKey(_groupId): _cachePayload(
          isPremium: true,
          expiresAt: future,
          autoRenew: true,
        ),
      });
      addTearDown(container.dispose);

      final state = container.read(subscriptionProvider);
      expect(state.requireValue.isPremium, true);
      expect(container.read(isPremiumProvider), true);
    });

    test('Cache abgelaufen + autoRenew=false → free + Cache überschrieben',
        () async {
      final past = DateTime.now().subtract(const Duration(days: 1));
      final container = await _makeContainer(initialPrefs: {
        _cacheKey(_groupId): _cachePayload(
          isPremium: true,
          expiresAt: past,
          autoRenew: false,
        ),
      });
      addTearDown(container.dispose);

      final state = container.read(subscriptionProvider);
      expect(state.requireValue.isPremium, false);

      final prefs = container.read(sharedPreferencesProvider);
      final raw = prefs.getString(_cacheKey(_groupId));
      expect(raw, isNotNull);
      final json = jsonDecode(raw!) as Map<String, dynamic>;
      expect(json['isPremium'], false);
    });

    test('Cache abgelaufen + autoRenew=true → bleibt premium (Server entscheidet)',
        () async {
      final past = DateTime.now().subtract(const Duration(days: 1));
      final container = await _makeContainer(initialPrefs: {
        _cacheKey(_groupId): _cachePayload(
          isPremium: true,
          expiresAt: past,
          autoRenew: true,
        ),
      });
      addTearDown(container.dispose);

      final state = container.read(subscriptionProvider);
      expect(state.requireValue.isPremium, true);
    });
  });

  group('SubscriptionNotifier._load()', () {
    test('online: free Resultat wird in den Cache geschrieben', () async {
      final repo = _MockSubscriptionRepository();
      when(() => repo.getSubscription(_groupId)).thenAnswer(
        (_) async => GroupSubscription(
          groupId: _groupId,
          status: SubscriptionStatus.free,
        ),
      );

      final container = await _makeContainer(
        initialPrefs: {},
        isOnline: true,
        repo: repo,
      );
      addTearDown(container.dispose);

      // Trigger build + background load.
      container.read(subscriptionProvider);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(subscriptionProvider);
      expect(state.requireValue.isPremium, false);

      final prefs = container.read(sharedPreferencesProvider);
      final raw = prefs.getString(_cacheKey(_groupId));
      expect(raw, isNotNull,
          reason: 'free Resultate müssen ebenfalls gecacht werden');
      final json = jsonDecode(raw!) as Map<String, dynamic>;
      expect(json['isPremium'], false);
    });

    test('online: premium Resultat überschreibt Cache', () async {
      final expires = DateTime.now().add(const Duration(days: 14));
      final repo = _MockSubscriptionRepository();
      when(() => repo.getSubscription(_groupId)).thenAnswer(
        (_) async => GroupSubscription(
          groupId: _groupId,
          status: SubscriptionStatus.premium,
          expiresAt: expires,
          autoRenew: true,
        ),
      );

      final container = await _makeContainer(
        initialPrefs: {
          _cacheKey(_groupId): _cachePayload(isPremium: false),
        },
        isOnline: true,
        repo: repo,
      );
      addTearDown(container.dispose);

      container.read(subscriptionProvider);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(subscriptionProvider).requireValue.isPremium, true);
      final prefs = container.read(sharedPreferencesProvider);
      final json =
          jsonDecode(prefs.getString(_cacheKey(_groupId))!) as Map<String, dynamic>;
      expect(json['isPremium'], true);
      expect(json['autoRenew'], true);
    });

    test('Expiry-Timer: autoRenew=false → flippt automatisch auf free',
        () async {
      // FakeAsync controls Timer + DateTime.now(); set up the container
      // INSIDE the zone so the notifier's timer runs on fake time.
      final repo = _MockSubscriptionRepository();

      fakeAsync((async) {
        late ProviderContainer container;
        SharedPreferences.setMockInitialValues({});
        // SharedPreferences.getInstance is async — pump the zone.
        SharedPreferences.getInstance().then((prefs) {
          // Pre-seed: premium, expires in 1h, won't renew.
          prefs.setString(
            _cacheKey(_groupId),
            _cachePayload(
              isPremium: true,
              expiresAt: DateTime.now().add(const Duration(hours: 1)),
              autoRenew: false,
            ),
          );
          container = ProviderContainer(overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            sessionProvider.overrideWithValue(
              const SessionState(userId: 'u1', groupId: _groupId),
            ),
            isOnlineProvider.overrideWithValue(false),
            subscriptionRepositoryProvider.overrideWithValue(repo),
          ]);

          // Initial read → premium from cache.
          expect(
            container.read(subscriptionProvider).requireValue.isPremium,
            true,
          );
        });
        async.flushMicrotasks();

        // Advance past expiry.
        async.elapse(const Duration(hours: 1, minutes: 1));

        expect(
          container.read(subscriptionProvider).requireValue.isPremium,
          false,
        );

        container.dispose();
      });
    });

    test('Expiry-Timer: autoRenew=true → ruft refresh auf', () async {
      final repo = _MockSubscriptionRepository();
      // After expiry, server says: still premium, fresh expires_at.
      when(() => repo.getSubscription(_groupId)).thenAnswer(
        (_) async => GroupSubscription(
          groupId: _groupId,
          status: SubscriptionStatus.premium,
          expiresAt: DateTime.now().add(const Duration(days: 30)),
          autoRenew: true,
        ),
      );

      final container = await _makeContainer(
        initialPrefs: {
          _cacheKey(_groupId): _cachePayload(
            isPremium: true,
            expiresAt: DateTime.now().add(const Duration(milliseconds: 50)),
            autoRenew: true,
          ),
        },
        isOnline: true,
        repo: repo,
      );
      addTearDown(container.dispose);

      container.read(subscriptionProvider);
      // Wait for the timer to fire and the refresh + reload to complete.
      await Future<void>.delayed(const Duration(milliseconds: 200));

      verify(() => repo.getSubscription(_groupId)).called(greaterThan(0));
      expect(
        container.read(subscriptionProvider).requireValue.isPremium,
        true,
      );
    });

    test('offline: kein Repo-Aufruf, Cache bleibt unverändert', () async {
      final repo = _MockSubscriptionRepository();
      final container = await _makeContainer(
        initialPrefs: {
          _cacheKey(_groupId): _cachePayload(isPremium: true),
        },
        isOnline: false,
        repo: repo,
      );
      addTearDown(container.dispose);

      container.read(subscriptionProvider);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => repo.getSubscription(any()));
      expect(container.read(subscriptionProvider).requireValue.isPremium, true);
    });
  });
}
