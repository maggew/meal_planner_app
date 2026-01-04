import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';

class ShowRecipeOverviewDetails extends StatelessWidget {
  final Recipe recipe;
  const ShowRecipeOverviewDetails({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: 0.0,
            offset: Offset(5.0, 5.0),
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
              shadows: [Shadow(color: Colors.black, offset: Offset(0, -5))],
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
    );
  }
}
