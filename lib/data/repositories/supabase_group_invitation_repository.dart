import 'dart:io';
import 'dart:math';

import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/data/model/group_invitation_model.dart';
import 'package:meal_planner/domain/entities/group_invitation.dart';
import 'package:meal_planner/domain/exceptions/group_exceptions.dart';
import 'package:meal_planner/domain/repositories/group_invitation_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseGroupInvitationRepository implements GroupInvitationRepository {
  final SupabaseClient _supabase;

  SupabaseGroupInvitationRepository({required SupabaseClient supabase})
      : _supabase = supabase;

  static String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I confusion
    final rng = Random.secure();
    return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  @override
  Future<GroupInvitation> createInvitation({
    required String groupId,
    required String createdBy,
    Duration validFor = const Duration(days: 7),
  }) async {
    try {
      // Delete any existing invitation for this group
      await _supabase
          .from(SupabaseConstants.groupInvitationsTable)
          .delete()
          .eq(SupabaseConstants.invitationGroupId, groupId);

      final code = _generateCode();
      final expiresAt = DateTime.now().toUtc().add(validFor);

      final response = await _supabase
          .from(SupabaseConstants.groupInvitationsTable)
          .insert({
            SupabaseConstants.invitationGroupId: groupId,
            SupabaseConstants.invitationCode: code,
            SupabaseConstants.invitationCreatedBy: createdBy,
            SupabaseConstants.invitationExpiresAt: expiresAt.toIso8601String(),
          })
          .select()
          .single();

      return GroupInvitationModel.fromSupabase(response);
    } on PostgrestException catch (e) {
      throw GroupCreationException('Einladung konnte nicht erstellt werden: $e');
    } on SocketException {
      throw GroupCreationException('Keine Internetverbindung');
    }
  }

  @override
  Future<GroupInvitation?> getActiveInvitation(String groupId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.groupInvitationsTable)
          .select()
          .eq(SupabaseConstants.invitationGroupId, groupId)
          .gt(SupabaseConstants.invitationExpiresAt, DateTime.now().toUtc().toIso8601String())
          .maybeSingle();

      if (response == null) return null;
      return GroupInvitationModel.fromSupabase(response);
    } on PostgrestException {
      return null;
    } on SocketException {
      return null;
    }
  }

  @override
  Future<String> joinViaInviteCode(String code) async {
    try {
      final result = await _supabase.rpc(
        'join_group_via_invite',
        params: {'invite_code': code.trim().toUpperCase()},
      );

      final response = result as Map<String, dynamic>;

      if (response.containsKey('error')) {
        final error = response['error'] as String;
        if (error == 'ALREADY_MEMBER') {
          throw AlreadyGroupMemberException(
            groupId: response['group_id'] as String?,
          );
        }
        throw InvitationExpiredException();
      }

      return response['group_id'] as String;
    } on AlreadyGroupMemberException {
      rethrow;
    } on InvitationExpiredException {
      rethrow;
    } on PostgrestException {
      throw InvitationExpiredException();
    } on SocketException {
      throw GroupCreationException('Keine Internetverbindung');
    }
  }

  @override
  Future<void> revokeInvitation(String invitationId) async {
    try {
      await _supabase
          .from(SupabaseConstants.groupInvitationsTable)
          .delete()
          .eq(SupabaseConstants.invitationId, invitationId);
    } on PostgrestException catch (e) {
      throw GroupDeletionException('Einladung konnte nicht gelöscht werden: $e');
    } on SocketException {
      throw GroupDeletionException('Keine Internetverbindung');
    }
  }
}
