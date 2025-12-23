import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/model/Recipe.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

class CookbookRecipeListItem extends StatelessWidget {
  final Recipe recipe;
  const CookbookRecipeListItem({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    final recipeImage = (recipe.imagePath.isEmpty ||
            recipe.imagePath == 'assets/images/default_pic_2.jpg')
        ? Image.asset('assets/images/default_pic_2.jpg', fit: BoxFit.cover)
        : Image.network(recipe.imagePath, fit: BoxFit.cover);
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(ShowRecipeRoute());
        // TODO:mit provider richtiges rezept übergeben?
      },
      child: Container(
        height: 100,
        margin: EdgeInsets.only(top: 5, bottom: 5, left: 5),
        color: Colors.white70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 10),
            Hero(
              tag: recipe.title,
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
                recipe.title,
                maxLines: 4,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
