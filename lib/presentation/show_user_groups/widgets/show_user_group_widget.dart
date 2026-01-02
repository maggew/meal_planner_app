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
    return Container(
      key: ValueKey(group.id),
      padding: EdgeInsets.only(top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShowUserGroupAvatar(group: group, isCurrentGroup: isCurrentGroup),
          Column(
            children: [
              SelectableText(
                group.id,
                style: TextStyle(
                  fontSize: 15,
                ),
                toolbarOptions: ToolbarOptions(copy: true),
              ),
              FittedBox(
                child: Text(
                  group.name,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
