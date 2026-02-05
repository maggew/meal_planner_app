import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';

class AddEditRecipePicture extends ConsumerStatefulWidget {
  final String? existingImageUrl; // ← Neu

  const AddEditRecipePicture({
    super.key,
    required this.existingImageUrl,
  });

  @override
  ConsumerState<AddEditRecipePicture> createState() => _AddRecipePictureState();
}

class _AddRecipePictureState extends ConsumerState<AddEditRecipePicture> {
  final TextEditingController _pictureNameController = TextEditingController();

  @override
  void dispose() {
    _pictureNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(imageManagerProvider);
    final newImage = images.photo;
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (newImage != null && newImage.path.isNotEmpty) {
      _pictureNameController.text = newImage.path.split('/').last;
    } else if (widget.existingImageUrl != null) {
      _pictureNameController.text = 'Aktuelles Bild';
    } else {
      _pictureNameController.text = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rezeptfoto",
          style: textTheme.displayMedium,
        ),
        Text(
          "(optional)",
          style: textTheme.displaySmall,
        ),
        SizedBox(height: 15),
        FittedBox(
          child: Row(
            children: [
              SizedBox(
                width: 270,
                height: 50,
                child: TextFormField(
                  controller: _pictureNameController,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  onTap: () async {
                    ref
                        .read(imageManagerProvider.notifier)
                        .pickImageFromGallery(
                            imageType: AnalysisImageType.photo);
                  },
                  readOnly: true,
                  enabled: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white30,
                    hintMaxLines: 2,
                    hintStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueGrey, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueGrey, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueGrey, width: 1.5),
                    ),
                    suffixIcon: Icon(AppIcons.upload, size: 25),
                  ),
                ),
              ),
              SizedBox(width: 20),
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
        SizedBox(height: 15),
        // Bild-Preview
        _buildImagePreview(newImage),
      ],
    );
  }

  Widget _buildImagePreview(file) {
    final newImage = file;
    final existingUrl = widget.existingImageUrl;

    if (newImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          newImage,
          height: 150,
          width: 150,
          fit: BoxFit.cover,
        ),
      );
    } else if (existingUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          existingUrl,
          height: 150,
          width: 150,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              height: 150,
              width: 150,
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      );
    }

    return SizedBox.shrink();
  }
}
