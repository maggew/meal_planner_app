import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_icons.dart';

class ShowRecipeBottomNavigationBar extends StatelessWidget {
  const ShowRecipeBottomNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightGreen[100],
      child: TabBar(
        tabs: [
          Tab(icon: Icon(AppIcons.shopping_list), text: "Übersicht"),
          Tab(icon: Icon(AppIcons.dish), text: "Kochmodus"),
        ],
      ),
    );
  }
}
