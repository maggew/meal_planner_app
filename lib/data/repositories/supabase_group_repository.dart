import 'dart:io';

import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/data/model/group_model.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/exceptions/group_exceptions.dart';
import 'package:meal_planner/domain/repositories/group_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseGroupRepository implements GroupRepository {
  final SupabaseClient _supabase;

  SupabaseGroupRepository({required SupabaseClient supabase})
      : _supabase = supabase;
  @override
  Future<void> createGroup(String groupId, String name, String imageUrl,
      String creatorUserId) async {
    try {
      await _supabase.from(SupabaseConstants.groupsTable).insert({
        SupabaseConstants.groupId: groupId,
        SupabaseConstants.groupName: name,
        SupabaseConstants.groupImageUrl: imageUrl
      });

      await _supabase.from(SupabaseConstants.groupMembersTable).insert({
        SupabaseConstants.memberGroupId: groupId,
        SupabaseConstants.memberUserId: creatorUserId,
        SupabaseConstants.memberRole: SupabaseConstants.roleAdmin,
      });
    } on PostgrestException catch (e) {
      throw GroupCreationException("Datenbankfehler: $e");
    } on SocketException {
      throw GroupCreationException("Keine Internetverbindung");
    } catch (e) {
      throw GroupCreationException("Unbekannter Fehler: $e");
    }
  }

  @override
  Future<Group> getGroup(String groupId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.groupsTable)
          .select()
          .eq(SupabaseConstants.groupId, groupId)
          .single();

      return GroupModel.fromSupabase(response);
    } on PostgrestException catch (e) {
      throw GroupNotFoundException("Datenbankfehler: $e");
    } on SocketException {
      throw GroupNotFoundException("Keine Internetverbindung");
    } catch (e) {
      throw GroupNotFoundException("Unbekannter Fehler: $e");
    }
  }

  @override
  Future<List<Group>> getGroupsByIds(List<String> groupIds) async {
    if (groupIds.isEmpty) return [];

    try {
      final response = await _supabase
          .from(SupabaseConstants.groupsTable)
          .select()
          .inFilter(SupabaseConstants.groupId, groupIds);

      return (response as List)
          .map((data) => GroupModel.fromSupabase(data))
          .toList();
    } on PostgrestException catch (e) {
      throw GroupNotFoundException("Datenbankfehler: $e");
    } on SocketException {
      throw GroupNotFoundException("Keine Internetverbindung");
    } catch (e) {
      throw GroupNotFoundException("Unbekannter Fehler: $e");
    }
  }

  @override
  Future<void> updateGroupPic(String groupId, String url) async {
    try {
      await _supabase
          .from(SupabaseConstants.groupsTable)
          .update({SupabaseConstants.groupImageUrl: url}).eq(
              SupabaseConstants.groupId, groupId);
    } on PostgrestException catch (e) {
      throw GroupUpdateException("Datenbankfehler: $e");
    } on SocketException {
      throw GroupUpdateException("Keine Internetverbindung");
    } catch (e) {
      throw GroupUpdateException("Unbekannter Fehler: $e");
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      // Erst Members löschen (Foreign Key Constraint)
      await _supabase
          .from(SupabaseConstants.groupMembersTable)
          .delete()
          .eq(SupabaseConstants.memberGroupId, groupId);

      // Dann Gruppe löschen
      await _supabase
          .from(SupabaseConstants.groupsTable)
          .delete()
          .eq(SupabaseConstants.groupId, groupId);
    } on PostgrestException catch (e) {
      throw GroupDeletionException("Datenbankfehler: $e");
    } on SocketException {
      throw GroupDeletionException("Keine Internetverbindung");
    } catch (e) {
      throw GroupDeletionException("Unbekannter Fehler: $e");
    }
  }

  @override
  Future<void> addMember(String groupId, String userId,
      {String role = 'member'}) async {
    try {
      await _supabase.from(SupabaseConstants.groupMembersTable).insert({
        SupabaseConstants.memberGroupId: groupId,
        SupabaseConstants.memberUserId: userId,
        SupabaseConstants.memberRole: role,
      });
    } on PostgrestException catch (e) {
      throw GroupMemberException("Datenbankfehler: $e");
    } on SocketException {
      throw GroupMemberException("Keine Internetverbindung");
    } catch (e) {
      throw GroupMemberException("Unbekannter Fehler: $e");
    }
  }

  @override
  Future<void> removeMember(String groupId, String userId) async {
    try {
      await _supabase
          .from(SupabaseConstants.groupMembersTable)
          .delete()
          .eq(SupabaseConstants.memberGroupId, groupId)
          .eq(SupabaseConstants.memberUserId, userId);
    } on PostgrestException catch (e) {
      throw GroupMemberException("Datenbankfehler: $e");
    } on SocketException {
      throw GroupMemberException("Keine Internetverbindung");
    } catch (e) {
      throw GroupMemberException("Unbekannter Fehler: $e");
    }
  }

  @override
  Future<List<String>> getMemberIds(String groupId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.groupMembersTable)
          .select(SupabaseConstants.memberUserId)
          .eq(SupabaseConstants.memberGroupId, groupId);

      return (response as List)
          .map((row) => row[SupabaseConstants.memberUserId] as String)
          .toList();
    } on PostgrestException catch (e) {
      throw GroupMemberException('Mitglieder konnten nicht geladen werden: $e');
    } on SocketException {
      throw GroupMemberException("Keine Internetverbindung");
    } catch (e) {
      throw GroupMemberException("Unbekannter Fehler: $e");
    }
  }

  @override
  Future<void> updateMemberRole(
      String groupId, String userId, String newRole) async {
    try {
      await _supabase
          .from(SupabaseConstants.groupMembersTable)
          .update({SupabaseConstants.memberRole: newRole})
          .eq(SupabaseConstants.memberGroupId, groupId)
          .eq(SupabaseConstants.memberUserId, userId);
    } on PostgrestException catch (e) {
      throw GroupMemberException('Mitglieder konnten nicht geladen werden: $e');
    } on SocketException {
      throw GroupMemberException("Keine Internetverbindung");
    } catch (e) {
      throw GroupMemberException("Unbekannter Fehler: $e");
    }
  }
}
