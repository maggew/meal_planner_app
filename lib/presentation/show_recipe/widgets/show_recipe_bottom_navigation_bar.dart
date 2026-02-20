import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_icons.dart';

class ShowRecipeBottomNavigationBar extends StatelessWidget {
  final TabController tabController;
  const ShowRecipeBottomNavigationBar({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      child: TabBar(
        controller: tabController,
        indicatorColor: colorScheme.primary,
        labelColor: colorScheme.primary,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(icon: Icon(AppIcons.shopping_list), text: "Übersicht"),
          Tab(icon: Icon(AppIcons.dish), text: "Kochmodus"),
        ],
      ),
    );
  }
}
