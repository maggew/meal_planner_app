import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';

class RegistrationImageInput extends ConsumerWidget {
  const RegistrationImageInput({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(imageManagerProvider);
    final newImage = images.photo;
    final imageName = newImage != null ? newImage.path.split('/').last : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(imageManagerProvider.notifier)
                      .pickImageFromGallery(imageType: AnalysisImageType.photo);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white30,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueGrey, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueGrey, width: 1.5),
                    ),
                    suffixIcon: Icon(AppIcons.upload, size: 25),
                  ),
                  child: Text(
                    imageName.isEmpty ? 'Bild auswählen' : imageName,
                    style: TextStyle(
                      color: imageName.isEmpty ? Colors.grey : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                ref
                    .read(imageManagerProvider.notifier)
                    .pickImageFromCamera(imageType: AnalysisImageType.photo);
              },
              icon: Icon(Icons.camera_alt_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
