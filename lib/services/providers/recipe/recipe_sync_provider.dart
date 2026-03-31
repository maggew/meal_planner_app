import 'package:meal_planner/data/repositories/cached_recipe_repository.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_sync_provider.g.dart';

@riverpod
Future<void> recipeDeltaSync(Ref ref) async {
  final repo = ref.read(recipeRepositoryProvider);
  if (repo is CachedRecipeRepository) {
    await repo.deltaSync();
  }
}
