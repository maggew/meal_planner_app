import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/group.dart';

class GroupModel extends Group {
  GroupModel({
    required super.name,
    required super.id,
    required super.imageUrl,
    super.showCarbTags = true,
  });

  factory GroupModel.fromSupabase(Map<String, dynamic> data) {
    return GroupModel(
      id: data[SupabaseConstants.groupId] as String,
      name: data[SupabaseConstants.groupName] as String? ?? '',
      imageUrl: data[SupabaseConstants.groupImageUrl] as String? ?? '',
      showCarbTags: data[SupabaseConstants.groupShowCarbTags] as bool? ?? true,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      SupabaseConstants.groupId: id,
      SupabaseConstants.groupName: name,
      SupabaseConstants.groupImageUrl: imageUrl,
      SupabaseConstants.groupShowCarbTags: showCarbTags,
    };
  }

  factory GroupModel.fromEntity(Group group) {
    return GroupModel(
      name: group.name,
      id: group.id,
      imageUrl: group.imageUrl,
      showCarbTags: group.showCarbTags,
    );
  }

  Group toEntity() {
    return Group(
      name: name,
      id: id,
      imageUrl: imageUrl,
      showCarbTags: showCarbTags,
    );
  }
}
