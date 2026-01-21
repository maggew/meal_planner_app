import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';

class ShowRecipeOverviewInstructions extends StatelessWidget {
  final Recipe recipe;
  const ShowRecipeOverviewInstructions({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
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
      child: Container(
        margin: EdgeInsets.all(10),
        child: Text(
          recipe.instructions,
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
