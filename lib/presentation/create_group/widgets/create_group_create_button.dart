import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/firebase_constants.dart';
import 'package:meal_planner/core/utils/uuid_generator.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class CreateGroupCreateButton extends ConsumerWidget {
  final TextEditingController groupNameController;
  final TextEditingController imagePathController;
  final ValueChanged<bool> onLoadingChanged;
  const CreateGroupCreateButton({
    super.key,
    required this.groupNameController,
    required this.imagePathController,
    required this.onLoadingChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final correctGroupName = _validateGroupName(groupNameController.text);

        if (!correctGroupName) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Gruppenname muss mindestens 3 Zeichen enthalten."),
            duration: Duration(seconds: 3),
          ));
          return;
        }

        onLoadingChanged(true);

        try {
          final imageManager = ref.read(imageManagerProvider);
          final image = imageManager.photo;
          String imageUrl = "";

          if (image != null) {
            final storageRepo = ref.read(storageRepositoryProvider);
            imageUrl = await storageRepo.uploadImage(
                image, FirebaseConstants.imagePathRecipe);
          }

          final groupRepo = ref.read(groupRepositoryProvider);
          final groupId = generateUuid();
          final creatorUserId = ref.read(sessionProvider).userId!;

          await groupRepo.createGroup(
            groupId,
            groupNameController.text,
            imageUrl,
            creatorUserId,
          );

          ref.read(imageManagerProvider.notifier).clearPhoto();

          final session = ref.read(sessionProvider.notifier);
          await session.setActiveGroup(groupId);

          if (context.mounted) {
            context.router.replace(const CookbookRoute());
          }
        } catch (e) {
          if (context.mounted) {
            print("Fehler: $e");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Fehler: $e"),
              duration: Duration(seconds: 3),
            ));
          }
        } finally {
          onLoadingChanged(false);
        }
      },
      child: Text(
        "erstellen",
      ),
    );
  }

  bool _validateGroupName(String? name) {
    if (name == null || name.isEmpty || name.length < 3) {
      return false;
    }
    return true;
  }
}
