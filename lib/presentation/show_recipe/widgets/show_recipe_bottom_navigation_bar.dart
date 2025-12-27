import 'package:flutter/material.dart';
import 'package:meal_planner/appstyle/app_icons.dart';

class ShowRecipeBottomNavigationBar extends StatelessWidget {
  final TabController tabController;
  const ShowRecipeBottomNavigationBar({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightGreen[100],
      child: TabBar(
        controller: tabController,
        tabs: [
          Tab(icon: Icon(AppIcons.shopping_list), text: "Übersicht"),
          Tab(icon: Icon(AppIcons.dish), text: "Kochmodus"),
        ],
      ),
    );
  }
}
