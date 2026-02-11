import 'dart:io';

import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final bool isEditing;
  final VoidCallback onEditImage;
  final File? pickedImage;
  const ProfilePicture({
    super.key,
    required this.imageUrl,
    required this.isEditing,
    required this.onEditImage,
    required this.pickedImage,
  });

  @override
  Widget build(BuildContext context) {
    final ImageProvider backgroundImage;
    if (pickedImage != null) {
      backgroundImage = FileImage(pickedImage!);
    } else if (imageUrl != null) {
      backgroundImage = NetworkImage(imageUrl!);
    } else {
      backgroundImage = const AssetImage('assets/default_pic.jpg');
    }
    return GestureDetector(
      onTap: isEditing ? onEditImage : null,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150, maxHeight: 150),
            child: AspectRatio(
              aspectRatio: 1,
              child: CircleAvatar(
                backgroundImage: backgroundImage,
              ),
            ),
          ),
          if (isEditing)
            const CircleAvatar(
              radius: 16,
              child: Icon(Icons.camera_alt, size: 16),
            ),
        ],
      ),
    );
  }
}
