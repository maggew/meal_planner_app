import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.uid,
    required super.name,
    super.currentGroup,
  });

  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel(
      uid: data[SupabaseConstants.userId] as String,
      name: data[SupabaseConstants.userName] as String? ?? '',
      currentGroup: data[SupabaseConstants.userCurrentGroup] as String?,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      SupabaseConstants.userId: uid,
      SupabaseConstants.userName: name,
      SupabaseConstants.userCurrentGroup: currentGroup,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      name: user.name,
      currentGroup: user.currentGroup,
    );
  }

  User toEntity() {
    return User(
      uid: uid,
      name: name,
      currentGroup: currentGroup,
    );
  }

  // factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
  //   return UserModel(
  //     uid: uid,
  //     name: data['name'] as String? ?? '',
  //     email: data['email'] as String? ?? '',
  //     groups: List<String>.from(data['groups'] as List? ?? []),
  //     currentGroup: data['current_group'] as String?,
  //   );
  // }
  //
  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'name': name,
  //     'email': email,
  //     'groups': groups,
  //     'current_group': currentGroup ?? '',
  //   };
  // }
}
