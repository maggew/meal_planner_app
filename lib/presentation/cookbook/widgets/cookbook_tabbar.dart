import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/categories.dart';
import 'package:meal_planner/presentation/common/vertical_tabbar.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_recipe_list.dart';
import 'package:meal_planner/presentation/cookbook/widgets/default_category_tabs.dart';

class CookbookTabbar extends StatelessWidget {
  const CookbookTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      child: VerticalTabs(
        disabledChangePageFromContentView: true,
        tabsElevation: 50,
        selectedTabBackgroundColor: Colors.lightGreen[100]!,
        indicatorColor: Colors.pink[100]!,
        backgroundColor: Colors.transparent,
        tabsWidth: 100,
        tabs: getDefaultCategoryTabs(),
        contents: [
          ..._getCategoryLists(),
          Container(
            child: Center(
              child: Text("Hier kommt noch was"),
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> _getCategoryLists() {
  List<Widget> categoryLists = [];
  for (String category in categoryNames) {
    categoryLists.add(CookbookRecipeList(category: category.toLowerCase()));
  }
  return categoryLists;
}
