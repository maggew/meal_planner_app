import 'package:meal_planner/domain/entities/group.dart';

abstract class GroupRepository {
  // CRUD Groups
  Future<void> createGroup(
      String groupId, String name, String imageUrl, String creatorUserId);
  Future<Group> getGroup(String groupId);
  Future<List<Group>> getGroupsByIds(List<String> groupIds);
  Future<void> updateGroupPic(String groupId, String url);
  Future<void> deleteGroup(String groupId);

  // Members
  Future<void> addMember(String groupId, String userId,
      {String role = 'member'});
  Future<void> removeMember(String groupId, String userId);
  Future<List<String>> getMemberIds(String groupId);
  Future<void> updateMemberRole(String groupId, String userId, String newRole);
}
