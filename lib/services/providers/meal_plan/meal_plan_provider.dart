import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/services/providers/groups/group_members_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

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
    String? recipeId,
    String? customName,
    String? cookId,
  }) async {
    await _ref.read(mealPlanRepositoryProvider).addEntry(
          date: date,
          mealType: mealType,
          recipeId: recipeId,
          customName: customName,
          cookId: cookId,
        );
  }

  Future<void> updateEntry(
    String localId, {
    String? recipeId,
    String? customName,
    String? cookId,
  }) async {
    await _ref.read(mealPlanRepositoryProvider).updateEntry(
          localId,
          recipeId: recipeId,
          customName: customName,
          cookId: cookId,
        );
  }

  Future<void> removeEntry(String localId) async {
    await _ref.read(mealPlanRepositoryProvider).removeEntry(localId);
  }

  Future<void> setCook(String localId, String? cookId) async {
    await _ref.read(mealPlanRepositoryProvider).setCook(localId, cookId);
  }
}

// Recipe name lookup from local cache – auto-disposes when not watched.
// Pass a non-empty recipeId; returns null if recipe not found.
final recipeNameProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, recipeId) async {
  if (recipeId.isEmpty) return null;
  final dao = ref.watch(recipeCacheDaoProvider);
  final recipe = await dao.getRecipeById(recipeId);
  return recipe?.name;
});

// Cook (User) lookup by userId within the current group
final cookUserProvider =
    FutureProvider.autoDispose.family<User?, String>((ref, userId) async {
  final groupId = ref.watch(sessionProvider).groupId;
  if (groupId == null) return null;
  final members = await ref.watch(groupMembersProvider(groupId).future);
  return members.where((u) => u.id == userId).firstOrNull;
});
