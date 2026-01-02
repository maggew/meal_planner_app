import 'package:flutter/material.dart';

class PlacerholderImage extends StatelessWidget {
  const PlacerholderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/group_pic.jpg',
      fit: BoxFit.cover,
    );
  }
}
