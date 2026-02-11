import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/presentation/show_user_groups/widgets/show_user_groups_body.dart';

@RoutePage()
class ShowUserGroupsPage extends StatelessWidget {
  const ShowUserGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(title: "Meine Gruppen"),
      scaffoldFloatingActionButton: FloatingActionButton(
          onPressed: () {
            context.router.push(CreateGroupRoute());
          },
          child: Icon(
            AppIcons.plus_1,
            color: Colors.black,
            size: 50,
          ),
          backgroundColor: Colors.lightGreen[100],
          elevation: 10),
      scaffoldFloatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      scaffoldBody: ShowUserGroupsBody(),
    );
  }
}
