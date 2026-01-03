import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/show_user_groups/widgets/show_user_group_widget.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class ShowUserGroupsGrid extends ConsumerWidget {
  final List<Group> groups;
  const ShowUserGroupsGrid({super.key, required this.groups});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? currentGroupId = ref.watch(sessionProvider).groupId;
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
      ),
      padding: EdgeInsets.only(top: 50),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final bool isCurrentGroup = currentGroupId == groups[index].id;
        return ShowUserGroupWidget(
          group: groups[index],
          isCurrentGroup: isCurrentGroup,
        );
      },
    );
  }
}
