import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String? imageUrl;

  const ProfilePicture({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final backGroundImage = (imageUrl == null)
        ? const AssetImage('assets/default_pic.jpg')
        : NetworkImage(imageUrl!) as ImageProvider;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 150, maxHeight: 150),
      child: AspectRatio(
        aspectRatio: 1,
        child: CircleAvatar(
          backgroundImage: backGroundImage,
        ),
      ),
    );
  }
}
