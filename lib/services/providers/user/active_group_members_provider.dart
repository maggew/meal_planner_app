import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

final activeGroupProvider = FutureProvider<Group?>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session.group != null) return session.group;

  final groupId = session.groupId;
  if (groupId == null) return null;

  return ref.read(groupRepositoryProvider).getGroup(groupId);
});

final activeGroupMembersProvider = FutureProvider<List<User>>((ref) async {
  final groupId = ref.watch(sessionProvider).groupId;
  if (groupId == null) return [];

  final groupRepo = ref.read(groupRepositoryProvider);
  return groupRepo.getGroupMembers(groupId);
});
