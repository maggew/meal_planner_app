import 'package:meal_planner/domain/entities/group_subscription.dart';

abstract class SubscriptionRepository {
  Future<GroupSubscription> getSubscription(String groupId);
}
