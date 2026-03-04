import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';

class AddEditRecipePicture extends ConsumerWidget {
  final String? existingImageUrl;

  const AddEditRecipePicture({
    super.key,
    required this.existingImageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(imageManagerProvider);
    final newImage = images.photo;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rezeptfoto",
          style: textTheme.titleLarge,
        ),
        Text(
          "(optional)",
          style: textTheme.bodySmall,
        ),
        _buildImageArea(context, ref, newImage, colorScheme),
        TextButton.icon(
          onPressed: () {
            ref
                .read(imageManagerProvider.notifier)
                .pickImageFromCamera(imageType: AnalysisImageType.photo);
          },
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text("Kamera"),
        ),
      ],
    );
  }

  Widget _buildImageArea(
    BuildContext context,
    WidgetRef ref,
    File? newImage,
    ColorScheme colorScheme,
  ) {
    if (newImage != null) {
      return GestureDetector(
        onTap: () => ref
            .read(imageManagerProvider.notifier)
            .pickImageFromGallery(imageType: AnalysisImageType.photo),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          child: Image.file(
            newImage,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
      );
    } else if (existingImageUrl != null) {
      return GestureDetector(
        onTap: () => ref
            .read(imageManagerProvider.notifier)
            .pickImageFromGallery(imageType: AnalysisImageType.photo),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          child: Image.network(
            existingImageUrl!,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        ref
            .read(imageManagerProvider.notifier)
            .pickImageFromGallery(imageType: AnalysisImageType.photo);
      },
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 28,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            Text(
              "Foto aus Galerie wählen",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
