import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/group_subscription.dart';
import 'package:meal_planner/domain/enums/subscription_status.dart';

void main() {
  group('GroupSubscription', () {
    test('isPremium gibt true bei status=premium', () {
      final sub = GroupSubscription(
        groupId: 'g1',
        status: SubscriptionStatus.premium,
      );
      expect(sub.isPremium, true);
    });

    test('isPremium gibt false bei status=free', () {
      final sub = GroupSubscription(
        groupId: 'g1',
        status: SubscriptionStatus.free,
      );
      expect(sub.isPremium, false);
    });

    test('Default-Status ist free', () {
      final sub = GroupSubscription(groupId: 'g1');
      expect(sub.status, SubscriptionStatus.free);
      expect(sub.isPremium, false);
    });

    test('copyWith ändert Status korrekt', () {
      final free = GroupSubscription(groupId: 'g1');
      final premium = free.copyWith(status: SubscriptionStatus.premium);
      expect(premium.isPremium, true);
      expect(premium.groupId, 'g1');
    });

    test('optionale Felder sind null per default', () {
      final sub = GroupSubscription(groupId: 'g1');
      expect(sub.subscriberUserId, isNull);
      expect(sub.productId, isNull);
      expect(sub.expiresAt, isNull);
      expect(sub.updatedAt, isNull);
    });
  });

  group('SubscriptionStatus enum', () {
    test('fromValue round-trip für alle Werte', () {
      for (final status in SubscriptionStatus.values) {
        expect(SubscriptionStatus.fromValue(status.value), status);
      }
    });

    test('fromValue unbekannter Wert → free', () {
      expect(SubscriptionStatus.fromValue('xyz'), SubscriptionStatus.free);
    });

    test('displayName ist für alle Werte nicht leer', () {
      for (final status in SubscriptionStatus.values) {
        expect(status.displayName.isNotEmpty, true);
      }
    });
  });
}
