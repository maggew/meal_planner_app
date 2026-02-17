import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_timer_provider.g.dart';

@riverpod
Future<Map<int, RecipeTimer>> recipeTimers(
  Ref ref,
  String recipeId,
) async {
  final repo = ref.read(recipeRepositoryProvider);
  final timers = await repo.getTimersForRecipe(recipeId);
  return {for (final t in timers) t.stepIndex: t};
}
