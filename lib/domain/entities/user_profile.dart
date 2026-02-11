import 'package:meal_planner/domain/entities/user.dart';

class UserProfile extends User {
  final String email;
  final DateTime createdAt;

  UserProfile({
    required super.id,
    required super.name,
    super.imageUrl,
    required this.email,
    required this.createdAt,
  });
}
