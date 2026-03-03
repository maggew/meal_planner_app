import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_recipe_list_item.dart';
import 'package:meal_planner/services/providers/groups/group_category_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_search_provider.dart';

class CookbookSearchResultsList extends ConsumerWidget {
  const CookbookSearchResultsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(groupCategoriesProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
      data: (categories) {
        final allCategories = categories.map((c) => c.name).toList();
        if (allCategories.isEmpty) return const SizedBox.shrink();

        final recipes = ref.watch(
          filteredRecipesProvider(
            category: allCategories.first,
            allCategories: allCategories,
          ),
        );

        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'Keine Rezepte gefunden',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          );
        }

        return Container(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
          padding: const EdgeInsets.only(top: 5, left: 5),
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
