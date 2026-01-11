import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

/// Lädt alle Gruppen des aktuellen Users
final userGroupsProvider = FutureProvider<List<Group>>((ref) async {
  print("usergroupsprovider starting");
  final session = ref.watch(sessionProvider);
  final userId = session.userId;
  print("userID: $userId");

  if (userId == null || userId.isEmpty) {
    print("userid null or empty");
    return [];
  }

  // 1. User-Repo: Hole Group-IDs
  print("staring userrepo");
  final userRepo = ref.read(userRepositoryProvider);
  final groupIds = await userRepo.getGroupIds(userId);
  print("number of groupIds: ${groupIds.length}");

  if (groupIds.isEmpty) {
    print("no groups found");
    return [];
  }

  // 2. Group-Repo: Hole Group-Daten
  print("starting grouprepo");
  final groupRepo = ref.read(groupRepositoryProvider);
  final groups = await groupRepo.getGroupsByIds(groupIds);
  for (var group in groups) {
    print(' - ${group.name} (id: ${group.id})');
  }
  return groups;
});
