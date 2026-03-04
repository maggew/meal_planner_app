import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/group_category.dart';

class GroupCategoryModel {
  final String id;
  final String groupId;
  final String name;
  final int sortOrder;
  final String? iconName;

  const GroupCategoryModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.sortOrder,
    this.iconName,
  });

  factory GroupCategoryModel.fromSupabase(Map<String, dynamic> data) {
    return GroupCategoryModel(
      id: data[SupabaseConstants.categoryId] as String,
      groupId: data[SupabaseConstants.categoryGroupId] as String,
      name: data[SupabaseConstants.categoryName] as String,
      sortOrder: data[SupabaseConstants.categorySortOrder] as int? ?? 0,
      iconName: data[SupabaseConstants.categoryIconName] as String?,
    );
  }

  Map<String, dynamic> toSupabaseInsert() {
    return {
      SupabaseConstants.categoryId: id,
      SupabaseConstants.categoryGroupId: groupId,
      SupabaseConstants.categoryName: name,
      SupabaseConstants.categorySortOrder: sortOrder,
      if (iconName != null) SupabaseConstants.categoryIconName: iconName,
    };
  }

  GroupCategory toEntity() {
    return GroupCategory(
      id: id,
      groupId: groupId,
      name: name,
      sortOrder: sortOrder,
      iconName: iconName,
    );
  }
}
