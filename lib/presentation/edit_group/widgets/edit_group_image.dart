import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';

class EditGroupImage extends ConsumerWidget {
  final Widget image;
  const EditGroupImage({super.key, required this.image});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget imageToShow = image;
    final imageManager = ref.watch(imageManagerProvider);
    final selectedImage = imageManager.photo;
    if (selectedImage != null) {
      imageToShow = Image.file(selectedImage);
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageToShow,
      ),
    );
  }
}
