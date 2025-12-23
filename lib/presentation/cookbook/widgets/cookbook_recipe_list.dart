import 'package:flutter/material.dart';
import 'package:meal_planner/model/Recipe.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_recipe_list_item.dart';
import 'package:meal_planner/services/database.dart';

class CookbookRecipeList extends StatelessWidget {
  final String category;
  const CookbookRecipeList({
    required this.category,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: Database().getRecipesFromCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Keine Rezepte gefunden'));
        }

        final recipes = snapshot.data!;

        return Container(
          color: Colors.lightGreen[100],
          margin: EdgeInsets.only(left: 10),
          padding: EdgeInsets.only(top: 5, left: 5),
          child: ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return CookbookRecipeListItem(recipe: recipes[index]);
            },
          ),
        );
      },
    );
  }
}
