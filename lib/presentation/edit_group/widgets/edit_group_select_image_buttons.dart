import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';

class EditGroupSelectImageButtons extends ConsumerWidget {
  const EditGroupSelectImageButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        IconButton(
            onPressed: () {
              ref
                  .read(imageManagerProvider.notifier)
                  .pickImageFromCamera(imageType: AnalysisImageType.photo);
            },
            icon: Icon(Icons.camera_alt_outlined)),
        IconButton(
            onPressed: () {
              ref
                  .read(imageManagerProvider.notifier)
                  .pickImageFromGallery(imageType: AnalysisImageType.photo);
            },
            icon: Icon(Icons.folder_outlined)),
      ],
    );
  }
}
