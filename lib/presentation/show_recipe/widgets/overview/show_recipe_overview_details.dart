import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/core/utils/double_formatting.dart';

class ShowRecipeOverviewDetails extends StatelessWidget {
  final Recipe recipe;
  const ShowRecipeOverviewDetails({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final int ingredientListLength = recipe.ingredients.length;
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
              itemCount: ingredientListLength,
              itemBuilder: (BuildContext context, int index) {
                final ingredient = recipe.ingredients[index];
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: 75,
                            child: Text(
                                "${ingredient.amount.toDisplayString()} ${ingredient.unit.displayName}")),
                        Expanded(child: Text(ingredient.name)),
                      ],
                    ),
                    if (index != ingredientListLength - 1) ...[
                      Divider(
                        thickness: 2,
                      ),
                    ],
                  ],
                );
              }),
        ],
      ),
    );
  }
}
