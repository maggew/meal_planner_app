import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/show_user_groups/widgets/show_user_errorpage.dart';
import 'package:meal_planner/presentation/show_user_groups/widgets/show_user_groups_grid.dart';
import 'package:meal_planner/presentation/show_user_groups/widgets/show_user_no_groups_found.dart';
import 'package:meal_planner/services/providers/user/user_groups_provider.dart';

class ShowUserGroupsBody extends ConsumerWidget {
  const ShowUserGroupsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(userGroupsProvider);
    return Column(
      children: [
        groupsAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.green)),
          error: (error, stack) => ShowUserErrorpage(),
          data: (groups) {
            if (groups.isEmpty) {
              return ShowUserNoGroupsFound();
            }
            return ShowUserGroupsGrid(groups: groups);
          },
        ),
      ],
    );
  }
}
