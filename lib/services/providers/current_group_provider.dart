import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

final currentGroupProvider = FutureProvider<Group?>((ref) async {
  final groupId = ref.watch(currentGroupIdStateProvider);

  if (groupId.isEmpty) {
    return null;
  }

  final groupRepo = ref.watch(groupRepositoryProvider);
  return await groupRepo.getCurrentGroup(groupId);
});
