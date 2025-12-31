import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/entities/user.dart';

class GroupModel extends Group {
  GroupModel({
    required super.name,
    required super.id,
    required super.imageUrl,
    required super.memberIDs,
  });

  factory GroupModel.fromFirestore(Map<String, dynamic> data) {
    return GroupModel(
      name: data['name'] as String? ?? '',
      id: data['id'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      memberIDs: List<String>.from(data['members'] as List? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'id': id,
      'imageUrl': imageUrl,
      'memberIDs': memberIDs,
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
