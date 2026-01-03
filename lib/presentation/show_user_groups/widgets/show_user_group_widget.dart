import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/show_user_groups/widgets/show_user_group_avatar.dart';

class ShowUserGroupWidget extends StatelessWidget {
  final Group group;
  final bool isCurrentGroup;
  const ShowUserGroupWidget({
    super.key,
    required this.group,
    required this.isCurrentGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShowUserGroupAvatar(group: group, isCurrentGroup: isCurrentGroup),
        Column(
          children: [
            FittedBox(
              child: Text(
                group.name,
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Gruppen ID: ",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SelectableText(
                  group.id,
                  style: Theme.of(context).textTheme.bodySmall,
                  onTap: () {
                    print("test, group.id: ${group.id} pressed");
                  },
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
          ],
        )
      ],
    );
  }
}
