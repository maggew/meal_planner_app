import 'package:meal_planner/core/constants/firebase_constants.dart';
import 'package:meal_planner/domain/entities/group.dart';

class GroupModel extends Group {
  GroupModel({
    required super.name,
    required super.id,
    required super.imageUrl,
    required super.memberIDs,
  });

  factory GroupModel.fromFirestore(Map<String, dynamic> data) {
    return GroupModel(
      name: data[FirebaseConstants.groupName] as String? ?? '',
      id: data[FirebaseConstants.groupId] as String? ?? '',
      imageUrl: data[FirebaseConstants.groupImageUrl] as String? ?? '',
      memberIDs: List<String>.from(
          data[FirebaseConstants.groupMembers] as List? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirebaseConstants.groupName: name,
      FirebaseConstants.groupId: id,
      FirebaseConstants.groupImageUrl: imageUrl,
      FirebaseConstants.groupMembers: memberIDs,
    };
  }

  factory GroupModel.fromEntity(Group group) {
    return GroupModel(
      name: group.name,
      id: group.id,
      imageUrl: group.imageUrl,
      memberIDs: group.memberIDs,
    );
  }

  Group toEntity() {
    return Group(
      name: name,
      id: id,
      imageUrl: imageUrl,
      memberIDs: memberIDs,
    );
  }
}
