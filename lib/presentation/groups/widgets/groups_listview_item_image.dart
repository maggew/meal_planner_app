import 'package:flutter/material.dart';

class GroupsListviewItemImage extends StatelessWidget {
  final String imageUrl;
  const GroupsListviewItemImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty || imageUrl == 'assets/images/group_pic.jpg') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset('assets/images/group_pic.jpg', fit: BoxFit.cover),
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return ClipRRect(
                borderRadius: BorderRadius.circular(8), child: child);
          }
          return Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    }
  }
}
