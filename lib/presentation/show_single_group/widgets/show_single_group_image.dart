import 'package:flutter/material.dart';

class ShowSingleGroupImage extends StatelessWidget {
  final Widget groupImage;
  const ShowSingleGroupImage({super.key, required this.groupImage});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 300),
      child: groupImage,
    );
  }
}
