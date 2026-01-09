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
  Future<void> updateUser(User user) async {
    try {
      await _supabase.from(SupabaseConstants.usersTable).update({
        SupabaseConstants.userName: user.name,
        SupabaseConstants.userCurrentGroup: user.currentGroup,
      }).eq(SupabaseConstants.userId, user.uid);
    } catch (e) {
      throw UserUpdateException(e.toString());
    }
  }

  @override
  Future<void> setActiveGroup(String uid, String groupId) async {
    try {
      await _supabase
          .from(SupabaseConstants.usersTable)
          .update({SupabaseConstants.userCurrentGroup: groupId}).eq(
              SupabaseConstants.userId, uid);
    } catch (e) {
      throw UserUpdateException('Active Group konnte nicht gesetzt werden: $e');
    }
  }

  @override
  Future<String?> getCurrentGroupId(String uid) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.usersTable)
          .select(SupabaseConstants.userCurrentGroup)
          .eq(SupabaseConstants.userId, uid)
          .maybeSingle();

      return response?[SupabaseConstants.userCurrentGroup] as String?;
    } catch (e) {
      throw UserNotFoundException(uid);
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
}
