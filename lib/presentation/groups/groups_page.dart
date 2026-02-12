import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/groups/widgets/groups_body.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

@RoutePage()
class GroupsPage extends ConsumerStatefulWidget {
  const GroupsPage({super.key});

  @override
  ConsumerState<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends ConsumerState<GroupsPage> {
  List<Group>? groups;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final session = ref.read(sessionProvider);
    final groupRepo = ref.read(groupRepositoryProvider);
    final loadedGroups = await groupRepo.getUserGroups(session.userId!);
    setState(() {
      groups = loadedGroups;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool sessionHasCurrentGroup =
        ref.watch(sessionProvider).group != null;
    final String appbarTitle = "Gruppen";
    final TextTheme textTheme = Theme.of(context).textTheme;
    final stack = context.router.stack;
    return AppBackground(
      scaffoldAppBar: isLoading
          ? AppBar(
              leading: Text(""),
              centerTitle: true,
              title: Text(
                appbarTitle,
                style: textTheme.displayMedium,
              ),
            )
          : (!isLoading && sessionHasCurrentGroup)
              ? CommonAppbar(title: appbarTitle)
              : AppBar(
                  leading: (stack.length == 1)
                      ? Text("")
                      : IconButton(
                          onPressed: () {
                            print("text");
                          },
                          icon: Icon(Icons.chevron_left)),
                  centerTitle: true,
                  title: Text(
                    appbarTitle,
                    style: textTheme.displayMedium,
                  ),
                ),
      scaffoldBody: GroupsBody(isLoading: isLoading, groups: groups),
    );
  }
}
