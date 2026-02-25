import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

// Stream of entries for a specific day – auto-disposes when not watched
final mealPlanStreamProvider = StreamProvider.autoDispose
    .family<List<MealPlanEntry>, DateTime>((ref, date) {
  final repo = ref.watch(mealPlanRepositoryProvider);
  return repo.watchEntriesForDate(date);
});

// Actions notifier – add / remove entries
final mealPlanActionsProvider = Provider<MealPlanActionsNotifier>((ref) {
  return MealPlanActionsNotifier(ref);
});

class MealPlanActionsNotifier {
  final Ref _ref;
  MealPlanActionsNotifier(this._ref);

  Future<void> addEntry({
    required DateTime date,
    required MealType mealType,
    required String recipeId,
  }) async {
    await _ref.read(mealPlanRepositoryProvider).addEntry(
          date: date,
          mealType: mealType,
          recipeId: recipeId,
        );
  }

  Future<void> removeEntry(String localId) async {
    await _ref.read(mealPlanRepositoryProvider).removeEntry(localId);
  }
}

// Recipe name lookup from local cache – auto-disposes when not watched
final recipeNameProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, recipeId) async {
  final dao = ref.watch(recipeCacheDaoProvider);
  final recipe = await dao.getRecipeById(recipeId);
  return recipe?.name;
});
