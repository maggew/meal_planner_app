import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';

class GroupModel extends Group {
  GroupModel({
    required super.name,
    required super.id,
    required super.imageUrl,
    super.settings,
  });

  factory GroupModel.fromSupabase(Map<String, dynamic> data) {
    final settings = GroupSettings.fromJson({
      'week_start_day': data[SupabaseConstants.groupWeekStartDay],
      'default_meal_slots': data[SupabaseConstants.groupDefaultMealSlots],
      'show_carb_tags': data[SupabaseConstants.groupShowCarbTags],
    });

    return GroupModel(
      id: data[SupabaseConstants.groupId] as String,
      name: data[SupabaseConstants.groupName] as String? ?? '',
      imageUrl: data[SupabaseConstants.groupImageUrl] as String? ?? '',
      settings: settings,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      SupabaseConstants.groupId: id,
      SupabaseConstants.groupName: name,
      SupabaseConstants.groupImageUrl: imageUrl,
      SupabaseConstants.groupWeekStartDay: settings.weekStartDay.name,
      SupabaseConstants.groupDefaultMealSlots:
          settings.defaultMealSlots.map((m) => m.value).toList(),
      SupabaseConstants.groupShowCarbTags: settings.showCarbTags,
    };
  }

  factory GroupModel.fromEntity(Group group) {
    return GroupModel(
      name: group.name,
      id: group.id,
      imageUrl: group.imageUrl,
      settings: group.settings,
    );
  }

  Group toEntity() {
    return Group(
      name: name,
      id: id,
      imageUrl: imageUrl,
      settings: settings,
    );
  }
}
