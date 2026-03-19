import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/group_subscription.dart';
import 'package:meal_planner/domain/enums/subscription_status.dart';

class GroupSubscriptionModel {
  final String groupId;
  final SubscriptionStatus status;
  final String? subscriberUserId;
  final String? productId;
  final DateTime? expiresAt;
  final DateTime? updatedAt;

  const GroupSubscriptionModel({
    required this.groupId,
    this.status = SubscriptionStatus.free,
    this.subscriberUserId,
    this.productId,
    this.expiresAt,
    this.updatedAt,
  });

  factory GroupSubscriptionModel.fromSupabase(Map<String, dynamic> data) {
    return GroupSubscriptionModel(
      groupId: data[SupabaseConstants.subscriptionGroupId] as String,
      status: SubscriptionStatus.fromValue(
        data[SupabaseConstants.subscriptionStatus] as String? ?? 'free',
      ),
      subscriberUserId:
          data[SupabaseConstants.subscriptionSubscriberUserId] as String?,
      productId: data[SupabaseConstants.subscriptionProductId] as String?,
      expiresAt: data[SupabaseConstants.subscriptionExpiresAt] != null
          ? DateTime.parse(
              data[SupabaseConstants.subscriptionExpiresAt] as String)
          : null,
      updatedAt: data[SupabaseConstants.subscriptionUpdatedAt] != null
          ? DateTime.parse(
              data[SupabaseConstants.subscriptionUpdatedAt] as String)
          : null,
    );
  }

  GroupSubscription toEntity() {
    return GroupSubscription(
      groupId: groupId,
      status: status,
      subscriberUserId: subscriberUserId,
      productId: productId,
      expiresAt: expiresAt,
      updatedAt: updatedAt,
    );
  }
}
