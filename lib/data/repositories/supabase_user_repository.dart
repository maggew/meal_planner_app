import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/firebase_constants.dart';
import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/data/model/user_model.dart';
import 'package:meal_planner/data/model/user_profile_model.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/domain/entities/user_profile.dart';
import 'package:meal_planner/domain/exceptions/user_exception.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';
import 'package:meal_planner/domain/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseUserRepository implements UserRepository {
  final SupabaseClient _supabase;
  final StorageRepository _storage;

  SupabaseUserRepository({
    required SupabaseClient supabase,
    required StorageRepository storage,
  })  : _supabase = supabase,
        _storage = storage;

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
  Future<UserProfile?> getUserProfileById(String uid) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.usersTable)
          .select()
          .eq(SupabaseConstants.userId, uid)
          .maybeSingle();

      if (response == null) return null;

      return UserProfileModel.fromSupabase(response);
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

  // @override
  // Future<void> ensureUserExists(String id, String name) async {
  //   try {
  //     await _supabase.from(SupabaseConstants.usersTable).upsert({
  //       SupabaseConstants.userId: id,
  //       SupabaseConstants.userName: name,
  //     });
  //   } catch (e) {
  //     throw UserCreationException(e.toString());
  //   }
  // }

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

  Future<void> updateUserProfile({
    required String userId,
    required File? image,
    required String name,
  }) async {
    try {
      String? imageUrl;
      String? oldImageUrl;

      // Bild hochladen falls vorhanden
      if (image != null) {
        imageUrl =
            await _storage.uploadImage(image, FirebaseConstants.imageUser);
        final result = await _supabase
            .from(SupabaseConstants.usersTable)
            .select(SupabaseConstants.userImage)
            .eq(SupabaseConstants.userId, userId)
            .maybeSingle();

        oldImageUrl = result?[SupabaseConstants.userImage] as String?;
      }

      // Supabase updaten
      final updates = <String, dynamic>{SupabaseConstants.userName: name};
      if (imageUrl != null) {
        updates[SupabaseConstants.userImage] = imageUrl;
      }

      await _supabase
          .from(SupabaseConstants.usersTable)
          .update(updates)
          .eq(SupabaseConstants.userId, userId);

      if (oldImageUrl != null) {
        _storage.deleteImage(oldImageUrl);
      }
    } on PostgrestException catch (e) {
      throw UserUpdateException("Datenbankfehler: ${e.message}");
    } catch (e) {
      throw UserUpdateException("User could not be updated: $e");
    }
  }
}
