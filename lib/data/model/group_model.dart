import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/group.dart';

class GroupModel extends Group {
  GroupModel({
    required super.name,
    required super.id,
    required super.imageUrl,
  });

  factory GroupModel.fromSupabase(Map<String, dynamic> data) {
    return GroupModel(
      id: data[SupabaseConstants.groupId] as String,
      name: data[SupabaseConstants.groupName] as String? ?? '',
      imageUrl: data[SupabaseConstants.groupImageUrl] as String? ?? '',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      SupabaseConstants.groupId: id,
      SupabaseConstants.groupName: name,
      SupabaseConstants.groupImageUrl: imageUrl,
    };
  }

  factory GroupModel.fromEntity(Group group) {
    return GroupModel(
      name: group.name,
      id: group.id,
      imageUrl: group.imageUrl,
    );
  }

  Group toEntity() {
    return Group(
      name: name,
      id: id,
      imageUrl: imageUrl,
    );
  }
  // factory GroupModel.fromFirestore(Map<String, dynamic> data) {
  //   return GroupModel(
  //     name: data[FirebaseConstants.groupName] as String? ?? '',
  //     id: data[FirebaseConstants.groupId] as String? ?? '',
  //     imageUrl: data[FirebaseConstants.groupImageUrl] as String? ?? '',
  //   );
  // }
  //
  // Map<String, dynamic> toFirestore() {
  //   return {
  //     FirebaseConstants.groupName: name,
  //     FirebaseConstants.groupId: id,
  //     FirebaseConstants.groupImageUrl: imageUrl,
  //   };
  // }
}
