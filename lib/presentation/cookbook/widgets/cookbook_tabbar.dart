// lib/presentation/cookbook/widgets/cookbook_tabbar.dart

import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/categories.dart';
import 'package:meal_planner/presentation/common/vertical_tabbar.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_recipe_list.dart';
import 'package:meal_planner/presentation/cookbook/widgets/default_category_tabs.dart';

class CookbookTabbar extends StatelessWidget {
  const CookbookTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    final allCategories = categoryNames.map((c) => c.toLowerCase()).toList();

    return VerticalTabs(
      disabledChangePageFromContentView: true,
      tabsElevation: 50,
      selectedTabBackgroundColor: Colors.lightGreen[100]!,
      indicatorColor: Colors.pink[100]!,
      backgroundColor: Colors.transparent,
      tabsWidth: 100,
      tabs: getDefaultCategoryTabs(),
      contents: [
        ..._getCategoryLists(allCategories),
        Container(
          child: Center(
            child: Text("Hier kommt noch was"),
          ),
        ),
      ],
    );
  }
}

List<Widget> _getCategoryLists(List<String> allCategories) {
  List<Widget> categoryLists = [];
  for (String category in categoryNames) {
    categoryLists.add(
      CookbookRecipeList(
        category: category.toLowerCase(),
        allCategories: allCategories,
      ),
    );
  }
  return categoryLists;
}
