import 'package:meal_planner/domain/entities/user.dart';

abstract class UserRepository {
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  });

  Future<User?> getUserById(String uid);

  Future<void> updateUser(User user);

  Future<void> addUserToGroup(String uid, String groupId);

  Future<void> removeUserFromGroup(String uid, String groupId);

  Future<void> setActiveGroup(String uid, String groupId);

  Future<String?> getCurrentGroupId(String uid);
}

