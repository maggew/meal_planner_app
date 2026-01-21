import 'package:meal_planner/domain/entities/user.dart';

abstract class UserRepository {
  Future<void> createUser({
    required String uid,
    required String name,
  });

  Future<User?> getUserById(String uid);

  Future<void> updateUser(User user);

  Future<void> setActiveGroup(String uid, String groupId);

  Future<String?> getCurrentGroupId(String uid);

  Future<List<String>> getGroupIds(String uid);

  Future<void> ensureUserExists(String id, String name);
}
