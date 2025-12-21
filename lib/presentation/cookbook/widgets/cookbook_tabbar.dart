import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/vertical_tabbar.dart';
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
        tabs: DefaultCategoryTabs,
        contents: [
          Container(height: 50, width: 50, color: Colors.red),
          Container(height: 50, width: 50, color: Colors.red),
          Container(height: 50, width: 50, color: Colors.red),
          Container(height: 50, width: 50, color: Colors.red),
          Container(height: 50, width: 50, color: Colors.red),
          Container(height: 50, width: 50, color: Colors.red),
          Container(height: 50, width: 50, color: Colors.red),
          Container(height: 50, width: 50, color: Colors.red),
          // buildRecipeOverview(Database().getRecipesFromCategory('soups')),
          // buildRecipeOverview(Database().getRecipesFromCategory('salads')),
          // buildRecipeOverview(
          //     Database().getRecipesFromCategory('sauces_dips')),
          // buildRecipeOverview(
          //     Database().getRecipesFromCategory('mainDishes')),
          // buildRecipeOverview(Database().getRecipesFromCategory('desserts')),
          // buildRecipeOverview(Database().getRecipesFromCategory('bakery')),
          // buildRecipeOverview(Database().getRecipesFromCategory('others')),
          // Container(
          //   child: Center(
          //     child: Text("Hier kommt noch was"),
          //   ),
          // ),
        ],
      ),
    );
  }
}
