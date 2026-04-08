import 'package:meal_planner/domain/enums/subscription_status.dart';

class GroupSubscription {
  final String groupId;
  final SubscriptionStatus status;
  final String? subscriberUserId;
  final String? productId;
  final DateTime? expiresAt;
  final DateTime? updatedAt;
  final bool autoRenew;

  const GroupSubscription({
    required this.groupId,
    this.status = SubscriptionStatus.free,
    this.subscriberUserId,
    this.productId,
    this.expiresAt,
    this.updatedAt,
    this.autoRenew = true,
  });

  bool get isPremium => status == SubscriptionStatus.premium;

  GroupSubscription copyWith({
    String? groupId,
    SubscriptionStatus? status,
    String? subscriberUserId,
    String? productId,
    DateTime? expiresAt,
    DateTime? updatedAt,
    bool? autoRenew,
  }) {
    return GroupSubscription(
      groupId: groupId ?? this.groupId,
      status: status ?? this.status,
      subscriberUserId: subscriberUserId ?? this.subscriberUserId,
      productId: productId ?? this.productId,
      expiresAt: expiresAt ?? this.expiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }
}
