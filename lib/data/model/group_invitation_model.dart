import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/group_invitation.dart';

class GroupInvitationModel extends GroupInvitation {
  GroupInvitationModel({
    required super.id,
    required super.groupId,
    required super.code,
    required super.createdBy,
    required super.expiresAt,
    required super.useCount,
    required super.createdAt,
  });

  factory GroupInvitationModel.fromSupabase(Map<String, dynamic> data) {
    return GroupInvitationModel(
      id: data[SupabaseConstants.invitationId] as String,
      groupId: data[SupabaseConstants.invitationGroupId] as String,
      code: data[SupabaseConstants.invitationCode] as String,
      createdBy: data[SupabaseConstants.invitationCreatedBy] as String,
      expiresAt: DateTime.parse(data[SupabaseConstants.invitationExpiresAt] as String),
      useCount: data[SupabaseConstants.invitationUseCount] as int? ?? 0,
      createdAt: DateTime.parse(data[SupabaseConstants.invitationCreatedAt] as String),
    );
  }
}
