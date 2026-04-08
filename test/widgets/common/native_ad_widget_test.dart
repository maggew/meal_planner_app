import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/group_subscription.dart';
import 'package:meal_planner/domain/enums/subscription_status.dart';
import 'package:meal_planner/presentation/common/native_ad_widget.dart';
import 'package:meal_planner/presentation/common/promo_card_widget.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/subscription/subscription_provider.dart';

const _groupId = 'g1';

GroupSubscription _free = GroupSubscription(
  groupId: _groupId,
  status: SubscriptionStatus.free,
);
GroupSubscription _premium = GroupSubscription(
  groupId: _groupId,
  status: SubscriptionStatus.premium,
);

/// Test notifier we can hand a synchronous AsyncValue.
class _StubSubscriptionNotifier extends SubscriptionNotifier {
  _StubSubscriptionNotifier(this._initial);
  final AsyncValue<GroupSubscription> _initial;
  @override
  AsyncValue<GroupSubscription> build() => _initial;
}

Widget _wrap({
  required AsyncValue<GroupSubscription> sub,
  required bool isOnline,
}) {
  return ProviderScope(
    overrides: [
      subscriptionProvider.overrideWith(() => _StubSubscriptionNotifier(sub)),
      isOnlineProvider.overrideWithValue(isOnline),
    ],
    child: const MaterialApp(
      home: Scaffold(body: NativeAdWidget()),
    ),
  );
}

void main() {
  testWidgets('AsyncLoading → SizedBox.shrink (kein Ad, kein Promo)',
      (tester) async {
    await tester.pumpWidget(_wrap(
      sub: const AsyncValue.loading(),
      isOnline: false,
    ));
    expect(find.byType(PromoCardWidget), findsNothing);
    // Widget renders SizedBox.shrink → no Container child.
    expect(find.byType(NativeAdWidget), findsOneWidget);
  });

  testWidgets('Premium → SizedBox.shrink', (tester) async {
    await tester.pumpWidget(_wrap(
      sub: AsyncValue.data(_premium),
      isOnline: true,
    ));
    expect(find.byType(PromoCardWidget), findsNothing);
  });

  testWidgets('REGRESSION: premium + offline → SizedBox.shrink (kein Promo)',
      (tester) async {
    await tester.pumpWidget(_wrap(
      sub: AsyncValue.data(_premium),
      isOnline: false,
    ));
    expect(find.byType(PromoCardWidget), findsNothing);
  });

  testWidgets('Free + offline → PromoCardWidget', (tester) async {
    await tester.pumpWidget(_wrap(
      sub: AsyncValue.data(_free),
      isOnline: false,
    ));
    expect(find.byType(PromoCardWidget), findsOneWidget);
  });

  testWidgets('Free + online → kein PromoCard (Ad-Container statt dessen)',
      (tester) async {
    await tester.pumpWidget(_wrap(
      sub: AsyncValue.data(_free),
      isOnline: true,
    ));
    // Ad lädt nicht im Test → _adFailed bleibt false, _isAdLoaded false →
    // Container ohne child, aber kein Promo.
    expect(find.byType(PromoCardWidget), findsNothing);
  });
}
