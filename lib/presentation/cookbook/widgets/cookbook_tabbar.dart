import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/vertical_tabbar.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_recipe_list.dart';
import 'package:meal_planner/presentation/cookbook/widgets/default_category_tabs.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

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

FutureBuilder buildRecipeOverview(Future future) {
  return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.green,
          ));
        } else {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            int numberRecipes;
            List<Widget> recipes = [];
            var recipePic;
            if (snapshot.hasData) {
              numberRecipes = snapshot.data.length;
            } else {
              numberRecipes = 0;
            }

            for (int i = 0; i < numberRecipes; i++) {
              if (snapshot.data[i]["recipe_pic"] == "" ||
                  snapshot.data[i]["recipe_pic"] == null) {
                recipePic = Image.asset(
                  'assets/images/default_pic_2.jpg',
                );
              } else {
                recipePic = Image.network(
                  snapshot.data[i]['recipe_pic'],
                  fit: BoxFit.fill,
                );
              }
              recipes.add(new Container(
                height: 100,
                child: _showRecipe(
                    context,
                    snapshot.data[i]['name'],
                    snapshot.data[i]['recipe_pic'],
                    snapshot.data[i]['ingredients'],
                    snapshot.data[i]['portions'],
                    snapshot.data[i]['instruction']),
                margin: EdgeInsets.only(top: 5, bottom: 5, left: 5),
                color: Colors.white70,
              ));
            }
            return Container(
              color: Colors.lightGreen[100],
              margin: EdgeInsets.only(left: 10),
              padding: EdgeInsets.only(top: 5, left: 5),
              child: ListView(children: recipes),
            );
          }
        }
      });
}

Widget _showRecipe(BuildContext context, String recipeTitle, String imagePath,
    List ingredients, int portions, String instructions) {
  Image recipeImage;

  if (imagePath == "" || imagePath == 'assets/images/default_pic_2.jpg') {
    recipeImage = Image.asset(
      'assets/images/default_pic_2.jpg',
      fit: BoxFit.cover,
    );
  } else {
    recipeImage = Image.network(imagePath, fit: BoxFit.cover);
  }

  return GestureDetector(
    onTap: () {
      AutoRouter.of(context).push(ShowRecipeRoute());
      // Navigator.pushNamed(context, RecipeScreen.route,
      //     arguments: Recipe(
      //         title: recipeTitle,
      //         imagePath: imagePath,
      //         ingredients: ingredients,
      //         portions: portions,
      //         instructions: instructions));
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 10),
        Hero(
          tag: recipeTitle,
          child: Image(
            width: 100,
            height: 80,
            fit: BoxFit.cover,
            image: recipeImage.image,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            recipeTitle,
            maxLines: 4,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}
