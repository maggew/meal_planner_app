import 'package:meal_planner/domain/entities/group_invitation.dart';

abstract class GroupInvitationRepository {
  /// Creates a new invitation for the group (deletes any existing one first).
  Future<GroupInvitation> createInvitation({
    required String groupId,
    required String createdBy,
    Duration validFor = const Duration(days: 7),
  });

  /// Returns the currently active (non-expired) invitation for a group, if any.
  Future<GroupInvitation?> getActiveInvitation(String groupId);

  /// Joins a group via invite code. Returns the group ID on success.
  Future<String> joinViaInviteCode(String code);

  /// Revokes (deletes) an invitation.
  Future<void> revokeInvitation(String invitationId);
}
