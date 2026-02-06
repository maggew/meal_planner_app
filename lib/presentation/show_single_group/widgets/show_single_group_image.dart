import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/placerholder_image.dart';

class ShowSingleGroupImage extends StatelessWidget {
  final String imageUrl;
  const ShowSingleGroupImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasValidImage = imageUrl.isNotEmpty;
    final Widget image = hasValidImage
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => const PlacerholderImage(),
            errorWidget: (_, __, ___) => const PlacerholderImage(),
          )
        : const PlacerholderImage();
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 300),
      child: image,
    );
  }
}
