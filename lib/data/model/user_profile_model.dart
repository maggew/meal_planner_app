import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.id,
    required super.name,
    super.imageUrl,
    required super.email,
    required super.createdAt,
  });

  factory UserProfileModel.fromSupabase(Map<String, dynamic> data) {
    return UserProfileModel(
      id: data[SupabaseConstants.userId] as String,
      name: data[SupabaseConstants.userName] as String? ?? '',
      imageUrl: data[SupabaseConstants.userImage] as String?,
      email: data[SupabaseConstants.userEmail] as String,
      createdAt:
          DateTime.parse(data[SupabaseConstants.userCreatedAt] as String),
    );
  }
}
