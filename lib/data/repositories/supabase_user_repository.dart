import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/data/model/user_model.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/domain/exceptions/user_exception.dart';
import 'package:meal_planner/domain/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseUserRepository implements UserRepository {
  final SupabaseClient _supabase;

  SupabaseUserRepository({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<void> createUser({required String uid, required String name}) async {
    try {
      await _supabase.from(SupabaseConstants.usersTable).insert({
        SupabaseConstants.userId: uid,
        SupabaseConstants.userName: name,
      });
    } catch (e) {
      throw UserCreationException(e.toString());
    }
  }

  @override
  Future<User?> getUserById(String uid) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.usersTable)
          .select()
          .eq(SupabaseConstants.userId, uid)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromSupabase(response);
    } catch (e) {
      throw UserNotFoundException(uid);
    }
  }

  @override
  Future<User?> getUserByFirebaseUid(String firebaseUid) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.usersTable)
          .select()
          .eq(SupabaseConstants.userFirebaseUid, firebaseUid)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromSupabase(response);
    } catch (e) {
      debugPrint('getUserByFirebaseUid fehlgeschlagen: $e');
      return null;
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      await _supabase.from(SupabaseConstants.usersTable).update({
        SupabaseConstants.userName: user.name,
      }).eq(SupabaseConstants.userId, user.id);
    } catch (e) {
      throw UserUpdateException(e.toString());
    }
  }

  @override
  Future<List<String>> getGroupIds(String uid) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.groupMembersTable)
          .select(SupabaseConstants.memberGroupId)
          .eq(SupabaseConstants.memberUserId, uid);

      return (response as List)
          .map((row) => row[SupabaseConstants.memberGroupId] as String)
          .toList();
    } catch (e) {
      throw UserNotFoundException('Gruppen für User $uid nicht gefunden: $e');
    }
  }

  @override
  Future<void> ensureUserExists(String id, String name) async {
    try {
      await _supabase.from(SupabaseConstants.usersTable).upsert({
        SupabaseConstants.userId: id,
        SupabaseConstants.userName: name,
      });
    } catch (e) {
      throw UserCreationException(e.toString());
    }
  }

  @override
  Future<void> updateUserImage(
      {required String uid, required String imageUrl}) async {
    try {
      await _supabase
          .from(SupabaseConstants.usersTable)
          .update({SupabaseConstants.userImage: imageUrl}).eq(
              SupabaseConstants.userId, uid);
    } on PostgrestException catch (e) {
      throw UserUpdateException("Datenbankfehler: ${e.message}");
    } catch (e) {
      throw UserUpdateException("Userimage could not be saved: $e");
    }
  }
}
