import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

@RoutePage()
class GroupsPage extends StatefulWidget {
  @override
  State<GroupsPage> createState() => _GroupsPage();
}

class _GroupsPage extends State<GroupsPage> {
  double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double getScreenHeightExcludeSafeArea(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return height - padding.top - padding.bottom;
  }

  double getHeightOfDropDownMenu(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return padding.top;
  }

  //Screen is locked to landscape mode
  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldBody: SizedBox(
        height: getScreenHeight(context),
        width: getScreenWidth(context),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 140,
              width: 140,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                  disabledForegroundColor: Colors.green[100]!.withOpacity(0.38),
                  disabledBackgroundColor: Colors.green[100]!.withOpacity(0.12),
                  elevation: 10,
                ),
                onPressed: () {
                  context.router.push(const CreateGroupRoute());
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 13),
                      child: Icon(
                        AppIcons.add,
                        color: Colors.black,
                        size: 80,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    FittedBox(
                      child: Text(
                        "Gruppe erstellen",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            SizedBox(
              height: 140,
              width: 140,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                  disabledForegroundColor: Colors.green[100]!.withOpacity(0.38),
                  disabledBackgroundColor: Colors.green[100]!.withOpacity(0.12),
                  elevation: 10,
                ),
                onPressed: () {
                  context.router.push(const JoinGroupRoute());
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      AppIcons.cheers,
                      color: Colors.black,
                      size: 75,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    FittedBox(
                      child: Text(
                        "Gruppe beitreten",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
