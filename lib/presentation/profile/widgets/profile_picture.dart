import 'dart:io';

import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final bool isEditing;
  final File? pickedImage;
  final VoidCallback? onPickFromCamera;
  final VoidCallback? onPickFromGallery;

  const ProfilePicture({
    super.key,
    required this.imageUrl,
    this.isEditing = false,
    this.pickedImage,
    this.onPickFromCamera,
    this.onPickFromGallery,
  });

  @override
  Widget build(BuildContext context) {
    final Widget avatar;
    if (pickedImage != null) {
      avatar = CircleAvatar(backgroundImage: FileImage(pickedImage!));
    } else if (imageUrl != null) {
      avatar = ClipOval(
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    } else {
      avatar = const CircleAvatar(
        backgroundImage: AssetImage('assets/default_pic.jpg'),
      );
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150, maxHeight: 150),
          child: AspectRatio(
            aspectRatio: 1,
            child: avatar,
          ),
        ),
        if (isEditing) ...[
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onPickFromCamera,
              child: const CircleAvatar(
                radius: 16,
                child: Icon(Icons.camera_alt, size: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: GestureDetector(
              onTap: onPickFromGallery,
              child: const CircleAvatar(
                radius: 16,
                child: Icon(Icons.folder, size: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
