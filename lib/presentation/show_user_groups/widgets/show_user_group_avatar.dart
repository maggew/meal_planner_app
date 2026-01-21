import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/common/placerholder_image.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

class ShowUserGroupAvatar extends StatelessWidget {
  final Group group;
  final bool isCurrentGroup;
  const ShowUserGroupAvatar({
    super.key,
    required this.group,
    required this.isCurrentGroup,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValidImage = group.imageUrl.isNotEmpty;
    final double avatarDiameter =
        MediaQuery.of(context).size.width / 2 - 3 * 20;
    return GestureDetector(
      onTap: () {
        context.router.push(const ShowSingleGroupRoute());
      },
      child: Container(
        width: avatarDiameter,
        height: avatarDiameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isCurrentGroup
              ? Border.all(color: Colors.pink[200]!, width: 3)
              : null,
        ),
        child: ClipOval(
          child: hasValidImage
              ? CachedNetworkImage(
                  imageUrl: group.imageUrl,
                  fit: BoxFit.cover,
                  width: avatarDiameter,
                  height: avatarDiameter,
                  placeholder: (_, __) => const PlacerholderImage(),
                  errorWidget: (_, __, ___) => const PlacerholderImage(),
                )
              : const PlacerholderImage(),
        ),
      ),
    );
  }
}
