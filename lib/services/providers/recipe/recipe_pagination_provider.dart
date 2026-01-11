import 'package:meal_planner/domain/entities/recipe.dart';
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
    print("before microtask");
    print("currentCategory: $_currentCategory");
    Future.microtask(() {
      print("in microtask");
      loadMore();
    });
    return const RecipesPaginationState();
  }

  Future<void> loadMore() async {
    print("state in beginning: ${state.recipes}");
    print("state in beginning: ${state.isLoading}");
    print("state in beginning: ${state.hasMore}");
    if (state.isLoading || !state.hasMore) {
      print("state ist empty");
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    print("state: $state");

    try {
      final recipeRepo = ref.read(recipeRepositoryProvider);

      final allRecipes =
          await recipeRepo.getRecipesByCategory(_currentCategory!);

      print(allRecipes);

      final offset = state.recipes.length;
      print(offset);
      final newRecipes = allRecipes.skip(offset).take(recipesPerPage).toList();
      print(newRecipes);

      final hasMore = newRecipes.length == recipesPerPage;
      print(hasMore);

      state = state.copyWith(
        recipes: [...state.recipes, ...newRecipes],
        isLoading: false,
        hasMore: hasMore,
      );
    } catch (e, stacktrace) {
      print("error: $e");
      print("stacktrace: $stacktrace");
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void refresh() {
    state = const RecipesPaginationState();
    Future.microtask(() => loadMore());
  }
}
