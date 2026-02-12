import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/profile/widgets/profile_groups_list.dart';
import 'package:meal_planner/presentation/profile/widgets/profile_name_widget.dart';
import 'package:meal_planner/presentation/profile/widgets/profile_picture.dart';
import 'package:meal_planner/services/providers/user/user_profile_provider.dart';

class ProfileBody extends ConsumerWidget {
  final bool isEditing;
  final TextEditingController nameController;
  final File? pickedImage;
  final VoidCallback onEditImage;
  const ProfileBody({
    super.key,
    required this.isEditing,
    required this.nameController,
    required this.pickedImage,
    required this.onEditImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return SizedBox(
      width: double.infinity,
      child: userAsync.when(
        data: (userProfile) {
          if (userProfile == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 15,
              children: [
                ProfilePicture(
                  imageUrl: userProfile.imageUrl,
                  isEditing: isEditing,
                  pickedImage: pickedImage,
                  onEditImage: onEditImage,
                ),
                ProfileNameWidget(
                  nameController: nameController,
                  isEditing: isEditing,
                  userProfile: userProfile,
                ),
                Text(userProfile.email),
                ProfileGroupsList(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Fehler: $e'),
      ),
    );
  }
}
