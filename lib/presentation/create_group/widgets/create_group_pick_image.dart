import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';

class CreateGroupPickImage extends ConsumerWidget {
  final TextEditingController imagePathController;
  const CreateGroupPickImage({super.key, required this.imagePathController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageManager = ref.watch(imageManagerProvider);
    return Column(
      children: [
        TextField(
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          controller: imagePathController,
          readOnly: true,
          enabled: true,
          onTap: () async {
            final imageManagerNotifier =
                ref.read(imageManagerProvider.notifier);
            await imageManagerNotifier.pickImageFromGallery(
                imageType: AnalysisImageType.photo);
            final imageManager = ref.read(imageManagerProvider);
            if (imageManager.photo != null) {
              imagePathController.text = imageManager.photo!.path;
            }
          },
          decoration: const InputDecoration(
            suffixIcon: Icon(AppIcons.upload, size: 25),
            hintMaxLines: 2,
          ),
        ),
        if (imageManager.photo != null) ...[
          Gap(20),
          Image.file(imageManager.photo!),
        ]
      ],
    );
  }
}
