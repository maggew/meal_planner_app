import 'package:meal_planner/services/providers/groups/group_category_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_search_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'first_non_empty_category_provider.g.dart';

/// Returns the ID of the first category (by sort_order) that contains at least
/// one recipe. Returns null if no recipes exist at all. Used for the one-time
/// auto-jump on cookbook open.
@riverpod
Future<String?> firstNonEmptyCategoryId(Ref ref) async {
  final categories = await ref.watch(groupCategoriesProvider.future);
  for (final category in categories) {
    final recipes =
        await ref.read(categoryRecipesProvider(category.id).future);
    if (recipes.isNotEmpty) return category.id;
  }
  return null;
}
