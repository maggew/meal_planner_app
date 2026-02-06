import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/firebase_constants.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class EditGroupsButton extends ConsumerWidget {
  final Group group;
  final TextEditingController groupNameController;
  final ValueChanged<bool> onLoadingChanged;
  const EditGroupsButton({
    super.key,
    required this.group,
    required this.groupNameController,
    required this.onLoadingChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        onLoadingChanged(true);
        final imageManager = ref.read(imageManagerProvider);
        final imageFile = imageManager.photo;

        final storageRepo = ref.read(storageRepositoryProvider);

        final oldImageUrl = group.imageUrl;
        String newImageUrl = group.imageUrl;

        try {
          if (imageFile != null) {
            newImageUrl = await storageRepo.uploadImage(
                imageFile, FirebaseConstants.imagePathGroups);
          }

          final groupRepo = ref.read(groupRepositoryProvider);
          await groupRepo.updateGroup(
              oldGroupId: group.id,
              newName: groupNameController.text,
              imageUrl: newImageUrl);

          if (imageFile != null &&
              oldImageUrl.isNotEmpty &&
              oldImageUrl != newImageUrl) {
            await storageRepo.deleteImage(group.imageUrl);
          }

          ref.read(imageManagerProvider.notifier).clearPhoto();
          ref.read(sessionProvider.notifier).reloadActiveGroup();
          context.router.push(const CookbookRoute());
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        } finally {
          onLoadingChanged(false);
        }
      },
      child: Text("bearbeiten abschließen"),
    );
  }
}
