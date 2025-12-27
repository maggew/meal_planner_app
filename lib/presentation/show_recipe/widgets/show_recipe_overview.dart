import 'package:flutter/material.dart';
import 'package:meal_planner/model/Recipe.dart';

class ShowRecipeOverview extends StatelessWidget {
  final Recipe recipe;
  final Image image;
  const ShowRecipeOverview(
      {super.key, required this.recipe, required this.image});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Hero(
            tag: recipe.name,
            child: image,
          ),
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  spreadRadius: 0.0,
                  offset: Offset(5.0, 5.0), // shadow direction: bottom right
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Portionen: ${recipe.portions.toString()}",
                  style: TextStyle(
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black,
                    color: Colors.transparent,
                    shadows: [
                      Shadow(color: Colors.black, offset: Offset(0, -5))
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: recipe.ingredients.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ingredient = recipe.ingredients[index];
                      return Column(
                        children: [
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: 75,
                                  child: Text(
                                      "${ingredient.amount.toString()}${ingredient.unit.displayName}")),
                              Text(ingredient.name),
                            ],
                          ),
                          SizedBox(height: 5),
                        ],
                      );
                    }),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  spreadRadius: 0.0,
                  offset: Offset(5.0, 5.0), // shadow direction: bottom right
                ),
              ],
            ),
            child: Container(
              margin: EdgeInsets.all(10),
              child: Text(
                recipe.instruction,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
