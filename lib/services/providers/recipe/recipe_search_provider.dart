import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_search_provider.g.dart';

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void set(String query) => state = query;
  void clear() => state = '';
}

@Riverpod(keepAlive: true)
Future<List<Recipe>> categoryRecipes(Ref ref, String categoryId) async {
  final sortOption = ref.watch(userSettingsProvider).recipeSortOption;
  final repo = ref.read(recipeRepositoryProvider);
  return repo.getRecipesByCategoryId(
    categoryId: categoryId,
    sortOption: sortOption,
    isDeleted: false,
  );
}

@riverpod
class IsSearchActive extends _$IsSearchActive {
  @override
  bool build() {
    final query = ref.watch(searchQueryProvider);
    return query.trim().length >= 3;
  }
}

@riverpod
Future<List<Recipe>> searchResults(Ref ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.length < 3) return [];
  final repo = ref.read(recipeRepositoryProvider);
  return repo.searchRecipes(query);
}
