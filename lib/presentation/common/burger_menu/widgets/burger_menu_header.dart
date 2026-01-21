import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/common/placerholder_image.dart';

class BurgerMenuHeader extends ConsumerWidget {
  final Group? group;
  const BurgerMenuHeader({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BoxFit boxFit = BoxFit.cover;
    final StackFit stackFit = StackFit.expand;
    final bool hasValidImage =
        (group?.imageUrl != null && group!.imageUrl.isNotEmpty);
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: stackFit,
        children: [
          Opacity(
            opacity: 0.8,
            child: hasValidImage
                ? CachedNetworkImage(
                    imageUrl: group!.imageUrl,
                    fit: boxFit,
                    placeholder: (_, __) => PlacerholderImage(),
                    errorWidget: (_, __, ___) => PlacerholderImage(),
                  )
                : PlacerholderImage(),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.keyboard_arrow_left),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
