import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/presentation/common/placerholder_image.dart';

class ShowSingleGroupMemberList extends StatelessWidget {
  final AsyncValue<List<User>> membersAsync;
  final Group group;
  const ShowSingleGroupMemberList({
    super.key,
    required this.membersAsync,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return membersAsync.when(
      data: (users) => ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (BuildContext, index) {
            User user = users[index];
            final hasValidImage = user.imageUrl != null;

            final Widget userImage = hasValidImage
                ? CachedNetworkImage(
                    imageUrl: group.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const PlacerholderImage(),
                    errorWidget: (_, __, ___) => const PlacerholderImage(),
                  )
                : const PlacerholderImage();

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Container(
                height: 80,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: userImage,
                    ),
                    Gap(20),
                    Text(user.name, style: textTheme.bodyLarge),
                  ],
                ),
              ),
            );
          }),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) {
        return Text('Fehler: $e');
      },
    );
  }
}
