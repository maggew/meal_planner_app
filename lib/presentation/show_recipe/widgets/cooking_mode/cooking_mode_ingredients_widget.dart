import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';

class CookingModeIngredientsWidget extends StatelessWidget {
  final List<Ingredient> ingredients;
  final bool isExpanded;
  const CookingModeIngredientsWidget(
      {super.key, required this.ingredients, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Expandierbarer Inhalt
        AnimatedCrossFade(
          firstChild: SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            color: Colors.amber.shade100,
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ingredients
                  .map((ing) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text("• ${ing.amount} ${ing.unit} ${ing.name}"),
                      ))
                  .toList(),
            ),
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

