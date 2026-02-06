import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

final groupMembersProvider =
    FutureProvider.family<List<User>, String>((ref, groupId) async {
  final groupRepo = ref.read(groupRepositoryProvider);
  return groupRepo.getGroupMembers(groupId);
});
