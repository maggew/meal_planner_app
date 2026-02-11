import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/presentation/show_single_group/widgets/show_single_group_clickable_text.dart';
import 'package:meal_planner/presentation/show_single_group/widgets/show_single_group_image.dart';
import 'package:meal_planner/presentation/show_single_group/widgets/show_single_group_member_list.dart';
import 'package:meal_planner/services/providers/groups/group_members_provider.dart';

@RoutePage()
class ShowSingleGroupPage extends ConsumerWidget {
  final Group group;

  const ShowSingleGroupPage({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final membersAsync = ref.watch(groupMembersProvider(group.id));

    return AppBackground(
      scaffoldAppBar: AppBar(
        title: Text(group.name, style: textTheme.displaySmall),
        centerTitle: true,
        leadingWidth: 65,
        leading: IconButton(
          onPressed: () {
            context.router.pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.router.push(EditGroupRoute(group: group));
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              context.router.push(const GroupsRoute());
            },
            icon: Icon(Icons.switch_left),
          )
        ],
      ),
      scaffoldBody: Column(
        children: [
          ShowSingleGroupImage(imageUrl: group.imageUrl),
          ShowSingleGroupClickableText(group: group),
          ShowSingleGroupMemberList(membersAsync: membersAsync, group: group),
        ],
      ),
    );
  }
}
