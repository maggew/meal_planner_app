import 'package:flutter/material.dart';
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
        tabsElevation: 50,
        selectedTabBackgroundColor: Colors.lightGreen[100]!,
        indicatorColor: Colors.pink[100]!,
        backgroundColor: Colors.transparent,
        tabsWidth: 100,
        tabs: getDefaultCategoryTabs(),
        contents: [
          CookbookRecipeList(category: 'soups'),
          CookbookRecipeList(category: 'salads'),
          CookbookRecipeList(category: 'sauces_dips'),
          CookbookRecipeList(category: 'mainDishes'),
          CookbookRecipeList(category: 'desserts'),
          CookbookRecipeList(category: 'bakery'),
          CookbookRecipeList(category: 'others'),
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
