// lib/services/providers/recipe/recipe_search_provider.dart

import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/services/providers/recipe/recipe_pagination_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_search_provider.g.dart';

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void set(String query) => state = query;
  void clear() => state = '';
}

@riverpod
class SearchAllCategories extends _$SearchAllCategories {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

@riverpod
class FilteredRecipes extends _$FilteredRecipes {
  @override
  List<Recipe> build({
    required String category,
    required List<String> allCategories,
  }) {
    final query = ref.watch(searchQueryProvider).toLowerCase().trim();
    final searchAll = ref.watch(searchAllCategoriesProvider);

    // Immer zuerst die eigene Kategorie watchten — stabiler Subscription-Anker,
    // verhindert Riverpod-Assertion beim pause/resume bei Navigation.
    final currentPagination = ref.watch(recipesPaginationProvider(category));

    if (query.length < 3) {
      return currentPagination.recipes;
    }

    if (searchAll) {
      // Über alle Kategorien suchen
      final allRecipes = <Recipe>[];
      final seenIds = <String>{};

      for (final cat in allCategories) {
        final paginationState = ref.watch(recipesPaginationProvider(cat));
        for (final recipe in paginationState.recipes) {
          if (recipe.id != null && !seenIds.contains(recipe.id)) {
            seenIds.add(recipe.id!);
            allRecipes.add(recipe);
          }
        }
      }

      return allRecipes
          .where((r) => r.name.toLowerCase().contains(query))
          .toList();
    } else {
      return currentPagination.recipes
          .where((r) => r.name.toLowerCase().contains(query))
          .toList();
    }
  }
}

@riverpod
class IsSearchActive extends _$IsSearchActive {
  @override
  bool build() {
    final query = ref.watch(searchQueryProvider);
    return query.trim().length >= 3;
  }
}
