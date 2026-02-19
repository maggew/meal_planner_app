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
    final ColorScheme _colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: _colorScheme.surface,
      child: TabBar(
        controller: tabController,
        indicatorColor: _colorScheme.primary,
        labelColor: _colorScheme.primary,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(icon: Icon(AppIcons.shopping_list), text: "Übersicht"),
          Tab(icon: Icon(AppIcons.dish), text: "Kochmodus"),
        ],
      ),
    );
  }
}
