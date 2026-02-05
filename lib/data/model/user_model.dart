import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
  });

  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel(
      id: data[SupabaseConstants.userId] as String,
      name: data[SupabaseConstants.userName] as String? ?? '',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      SupabaseConstants.userId: id,
      SupabaseConstants.userName: name,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
    );
  }
}
