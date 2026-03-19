import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/data/model/group_subscription_model.dart';
import 'package:meal_planner/domain/entities/group_subscription.dart';
import 'package:meal_planner/domain/enums/subscription_status.dart';
import 'package:meal_planner/domain/repositories/subscription_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSubscriptionRepository implements SubscriptionRepository {
  final SupabaseClient _supabase;

  SupabaseSubscriptionRepository({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<GroupSubscription> getSubscription(String groupId) async {
    final response = await _supabase
        .from(SupabaseConstants.subscriptionsTable)
        .select()
        .eq(SupabaseConstants.subscriptionGroupId, groupId)
        .maybeSingle();

    if (response == null) {
      return GroupSubscription(
        groupId: groupId,
        status: SubscriptionStatus.free,
      );
    }

    return GroupSubscriptionModel.fromSupabase(response).toEntity();
  }
}
