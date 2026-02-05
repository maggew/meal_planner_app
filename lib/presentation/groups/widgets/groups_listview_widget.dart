import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/groups/widgets/groups_create_join_button.dart';
import 'package:meal_planner/presentation/groups/widgets/groups_listview_item.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

class GroupsListviewWidget extends StatelessWidget {
  final ValueChanged<bool> onLoadingChanged;
  final List<Group> groups;
  const GroupsListviewWidget({
    super.key,
    required this.groups,
    required this.onLoadingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final joinGroupColor =
        (groups.length % 2 == 1) ? Colors.green[100]! : Colors.green[300]!;
    final createGroupColor = (joinGroupColor == Colors.green[100])
        ? Colors.green[300]!
        : Colors.green[100]!;
    return Column(
      children: [
        ListView.separated(
          separatorBuilder: (context, index) => Gap(5),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          primary: false,
          itemCount: groups.length,
          itemBuilder: (BuildContext, index) {
            final Color color =
                (index % 2 == 0) ? Colors.green[100]! : Colors.green[300]!;
            return GroupsListviewItem(
              group: groups[index],
              color: color,
              onLoadingChanged: onLoadingChanged,
            );
          },
        ),
        Gap(5),
        GroupsCreateJoinButton(
          iconData: AppIcons.cheers,
          buttonText: "Gruppe beitreten",
          boxColor: createGroupColor,
          onPressed: () {
            context.router.push(const JoinGroupRoute());
          },
        ),
        Gap(5),
        GroupsCreateJoinButton(
          iconData: AppIcons.add,
          buttonText: "Gruppe erstellen",
          boxColor: joinGroupColor,
          onPressed: () {
            context.router.push(const CreateGroupRoute());
          },
        ),
      ],
    );
  }
}
