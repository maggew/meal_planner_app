import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/categories.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_recipe_list_item.dart';
import 'package:meal_planner/services/providers/recipe/recipe_search_provider.dart';

class CookbookSearchResultsList extends ConsumerWidget {
  const CookbookSearchResultsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCategories = categoryNames.map((c) => c.toLowerCase()).toList();

    // Bei globaler Suche brauchen wir eine beliebige Kategorie als Fallback
    final recipes = ref.watch(
      filteredRecipesProvider(
        category: allCategories.first,
        allCategories: allCategories,
      ),
    );

    if (recipes.isEmpty) {
      return Center(
        child: Text('Keine Rezepte gefunden'),
      );
    }

    return Container(
      color: Colors.lightGreen[100],
      padding: const EdgeInsets.only(top: 5, left: 5),
      child: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return CookbookRecipeListItem(recipe: recipes[index]);
        },
      ),
    );
  }
}
