import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/join_group/widgets/join_group_body.dart';

@RoutePage()
class JoinGroupPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<JoinGroupPage> createState() => _JoinGroupPage();
}

class _JoinGroupPage extends ConsumerState<JoinGroupPage> {
  late final TextEditingController groupIdController;

  //Screen is locked to landscape mode
  @override
  void initState() {
    super.initState();
    groupIdController = TextEditingController();
  }

  @override
  void dispose() {
    groupIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Stack(
      children: [
        AppBackground(
            scaffoldBody: JoinGroupBody(groupIdController: groupIdController),
            applyScreenPadding: true,
            scaffoldAppBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  context.router.pop();
                },
                icon: Icon(Icons.chevron_left),
              ),
              leadingWidth: 85,
              title: Text("Gruppe beitreten", style: textTheme.displaySmall),
              centerTitle: true,
            )),
      ],
    );
  }
}
