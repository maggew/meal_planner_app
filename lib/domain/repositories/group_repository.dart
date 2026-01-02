import 'dart:io';

import 'package:meal_planner/domain/entities/group.dart';

abstract class GroupRepository {
  Future<void> createGroup(
      String groupID, String name, String imageUrl, String creatorUserID);

  Future<void> updateGroupPic(String groupID, String url);

  Future<Group> getCurrentGroup(String groupID);

  Future<List<Group>> getGroupsByIds(List<String> groupIds);

  Future<Map<String, dynamic>?> getSingleGroupInfo(String groupID);

  Future<void> updateGroupUsers(String groupID, String userID);

  Future<String> uploadGroupImage(File imageFile);

  Future<void> deleteRecipeImage(String imageUrl);
}
