import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

class CookbookRecipeListItem extends StatelessWidget {
  final Recipe recipe;
  const CookbookRecipeListItem({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    final recipeImage = (recipe.imageUrl == null ||
            recipe.imageUrl!.isEmpty ||
            recipe.imageUrl == 'assets/images/default_pic_2.jpg')
        ? Image.asset('assets/images/caticorn.png', fit: BoxFit.cover)
        : Image.network(recipe.imageUrl!, fit: BoxFit.cover);
    return GestureDetector(
      onTap: () {
        context.router
            .push(ShowRecipeRoute(recipe: recipe, image: recipeImage));
      },
      child: Container(
        height: 100,
        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 10),
            Hero(
              tag: recipe.name,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                  image: recipeImage.image,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                recipe.name,
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
