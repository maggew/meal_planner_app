import 'package:flutter/material.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_add_recipe.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_searchbar.dart';
import 'package:meal_planner/widgets/BurgerMenu_widget.dart';

class CookbookBody extends StatelessWidget {
  const CookbookBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: BurgerMenu(width: 0.7),
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          icon: Icon(Icons.wallet), //FaIcon(FontAwesomeIcons.bars),
          onPressed: () {
            //scaffoldKey.currentState.openDrawer();
          },
        ),
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Kochbuch",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        centerTitle: true,
        actions: [
          Container(
            height: 40,
            width: 40,
            child: FloatingActionButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) => CookbookAddRecipe()),
              backgroundColor: Colors.lightGreen[100],
              child: Icon(
                AppIcons.plus_1,
                size: 35,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 10),
          CookbookSearchbar(),
          SizedBox(height: 20),
          Flexible(
              fit: FlexFit.tight,
              child: Container(height: 50, width: 50, color: Colors.red)
              // child: VerticalTabs(
              //   tabsElevation: 50,
              //   selectedTabBackgroundColor: Colors.lightGreen[100],
              //   indicatorColor: Colors.pink[100],
              //   backgroundColor: Colors.transparent,
              //   tabsWidth: 100,
              //   tabs: getCategoryTabs(),
              //   contents: [
              //     buildRecipeOverview(
              //         Database().getRecipesFromCategory('soups')),
              //     buildRecipeOverview(
              //         Database().getRecipesFromCategory('salads')),
              //     buildRecipeOverview(
              //         Database().getRecipesFromCategory('sauces_dips')),
              //     buildRecipeOverview(
              //         Database().getRecipesFromCategory('mainDishes')),
              //     buildRecipeOverview(
              //         Database().getRecipesFromCategory('desserts')),
              //     buildRecipeOverview(
              //         Database().getRecipesFromCategory('bakery')),
              //     buildRecipeOverview(
              //         Database().getRecipesFromCategory('others')),
              //     Container(
              //       child: Center(
              //         child: Text("Hier kommt noch was"),
              //       ),
              //     ),
              //   ],
              // ),
              ),
        ],
      ),
    );
  }
}
