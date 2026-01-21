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
          // Portions
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
          // Sections + Ingredients
          ...recipe.ingredientSections.map((section) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.title), const SizedBox(height: 8),
                // Ingredients of section
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: section.items.length,
                  itemBuilder: (context, index) {
                    final ingredient = section.items[index];

                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 75,
                              child: Text(
                                "${ingredient.amount} ${ingredient.unit.displayName}",
                              ),
                            ),
                            Expanded(child: Text(ingredient.name)),
                          ],
                        ),
                        if (index != section.items.length - 1)
                          const Divider(thickness: 2),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
          // ListView.builder(
          //     physics: NeverScrollableScrollPhysics(),
          //     shrinkWrap: true,
          //     itemCount: ingredientListLength,
          //     itemBuilder: (BuildContext context, int index) {
          //       final ingredient = recipe.ingredients[index];
          //       return Column(
          //         children: [
          //           Row(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             mainAxisAlignment: MainAxisAlignment.start,
          //             children: [
          //               SizedBox(
          //                   width: 75,
          //                   child: Text(
          //                       "${ingredient.amount} ${ingredient.unit.displayName}")),
          //               Expanded(child: Text(ingredient.name)),
          //             ],
          //           ),
          //           if (index != ingredientListLength - 1) ...[
          //             Divider(
          //               thickness: 2,
          //             ),
          //           ],
          //         ],
          //       );
          //     }),
        ],
      ),
    );
  }
}
