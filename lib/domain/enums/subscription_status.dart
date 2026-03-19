enum SubscriptionStatus {
  free,
  premium;

  String get value => name;

  String get displayName => switch (this) {
        SubscriptionStatus.free => 'Kostenlos',
        SubscriptionStatus.premium => 'Premium',
      };

  static SubscriptionStatus fromValue(String value) => switch (value) {
        'free' => SubscriptionStatus.free,
        'premium' => SubscriptionStatus.premium,
        _ => SubscriptionStatus.free,
      };
}
