import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';

class RegistrationImagePreview extends ConsumerWidget {
  const RegistrationImagePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(imageManagerProvider);
    final image = images.photo;

    if (image == null) {
      return SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300),
        child: CircleAvatar(
          radius: 150,
          backgroundImage: FileImage(image),
        ),
      ),
    );
  }
}
