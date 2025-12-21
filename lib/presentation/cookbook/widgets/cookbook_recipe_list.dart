import 'package:flutter/material.dart';
import 'package:meal_planner/model/RecipeInfo.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_recipe_list_item.dart';

class CookbookRecipeList extends StatelessWidget {
  final List<Recipe> recipeList;
  const CookbookRecipeList({
    required this.recipeList,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: recipeList.length,
        itemExtent: 100,
        itemBuilder: (context, index) {
          return Container(
            child: CookbookRecipeListItem(recipe: recipeList[index]),
            margin: EdgeInsets.only(top: 5, bottom: 5, left: 5),
            color: Colors.white70,
          );
        });
  }
}
