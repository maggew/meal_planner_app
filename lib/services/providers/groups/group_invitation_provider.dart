import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group_invitation.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_invitation_provider.g.dart';

@riverpod
Future<GroupInvitation?> activeGroupInvitation(Ref ref) async {
  final groupId = ref.watch(sessionProvider.select((s) => s.groupId));
  if (groupId == null) return null;

  final repo = ref.watch(groupInvitationRepositoryProvider);
  return repo.getActiveInvitation(groupId);
}
