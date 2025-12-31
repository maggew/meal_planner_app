import 'package:meal_planner/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.groups,
    super.currentGroup,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      groups: List<String>.from(data['groups'] as List? ?? []),
      currentGroup: data['current_group'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'groups': groups,
      'current_group': currentGroup ?? '',
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      groups: user.groups,
      currentGroup: user.currentGroup,
    );
  }

  User toEntity() {
    return User(
      uid: uid,
      name: name,
      email: email,
      groups: groups,
      currentGroup: currentGroup,
    );
  }
}
