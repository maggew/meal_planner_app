import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/user_profile.dart';

class ProfileNameWidget extends StatelessWidget {
  final TextEditingController nameController;
  final bool isEditing;
  final UserProfile userProfile;
  const ProfileNameWidget({
    super.key,
    required this.nameController,
    required this.isEditing,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return SizedBox(
        width: 250,
        child: TextField(
          controller: nameController,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
      );
    }
    return Text(userProfile.name);
  }
}
