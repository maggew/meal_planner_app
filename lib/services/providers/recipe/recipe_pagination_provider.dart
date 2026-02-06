import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/exceptions/recipe_exceptions.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_pagination_provider.g.dart';

const int recipesPerPage = 25;

class RecipesPaginationState {
  final List<Recipe> recipes;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const RecipesPaginationState({
    this.recipes = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  RecipesPaginationState copyWith({
    List<Recipe>? recipes,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return RecipesPaginationState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

@Riverpod(keepAlive: true)
class RecipesPagination extends _$RecipesPagination {
  String? _currentCategory;

  RecipesPaginationState build(String category) {
    _currentCategory = category;
    Future.microtask(() {
      loadMore();
    });
    return const RecipesPaginationState();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    List<Recipe> newRecipes = [];
    String? error;
    bool? hasMore;

    try {
      final recipeRepo = ref.read(recipeRepositoryProvider);

      final allRecipes =
          await recipeRepo.getRecipesByCategory(_currentCategory!, false);

      final offset = state.recipes.length;
      newRecipes = allRecipes.skip(offset).take(recipesPerPage).toList();

      hasMore = newRecipes.length == recipesPerPage;
    } on RecipeNotFoundException catch (e) {
      error = e.toString();
    } catch (e, stacktrace) {
      debugPrint("error: $e\n$stacktrace");
      error = e.toString();
    } finally {
      state = state.copyWith(
        recipes: [...state.recipes, ...newRecipes],
        isLoading: false,
        hasMore: hasMore ?? state.hasMore,
        error: error,
      );
    }
  }

  void refresh() {
    state = const RecipesPaginationState();
    Future.microtask(() => loadMore());
  }
}
