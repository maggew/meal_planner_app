import 'dart:io';

import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<void> createUser({
    required String uid,
    required String name,
  });

  Future<User?> getUserById(String uid);
  Future<UserProfile?> getUserProfileById(String uid);

  Future<User?> getUserByFirebaseUid(String firebaseUid);

  Future<void> updateUser(User user);
  Future<void> updateUserImage({required String uid, required String imageUrl});
  Future<void> updateUserProfile({
    required String userId,
    required File? image,
    required String name,
  });

  Future<List<String>> getGroupIds(String uid);

  Future<void> ensureUserExists(String id, String name);
}
