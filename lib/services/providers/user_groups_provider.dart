import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

/// Lädt alle Gruppen des aktuellen Users
final userGroupsProvider = FutureProvider<List<Group>>((ref) async {
  final session = ref.watch(sessionProvider);
  final userId = session.userId;

  if (userId == null || userId.isEmpty) {
    return [];
  }

  // 1. User-Repo: Hole Group-IDs
  final userRepo = ref.read(userRepositoryProvider);
  final groupIds = await userRepo.getGroupIds(userId);

  if (groupIds.isEmpty) {
    return [];
  }

  // 2. Group-Repo: Hole Group-Daten
  final groupRepo = ref.read(groupRepositoryProvider);
  final groups = await groupRepo.getGroupsByIds(groupIds);
  return groups;
});
