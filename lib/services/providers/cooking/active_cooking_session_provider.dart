import 'package:meal_planner/domain/entities/cooking_recipe_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_cooking_session_provider.g.dart';

class ActiveCookingSessionState {
  final List<CookingRecipeEntry> recipes;
  final String? currentRecipeId;

  /// Tracks whether the user last viewed the cooking-mode tab (vs overview)
  /// in single-recipe mode. Used to restore the correct tab when the user
  /// re-opens the recipe (e.g. via the mini-bar).
  final bool wasInCookingMode;

  const ActiveCookingSessionState({
    this.recipes = const [],
    this.currentRecipeId,
    this.wasInCookingMode = false,
  });

  bool get isActive => recipes.isNotEmpty;

  bool isRecipeActive(String recipeId) =>
      recipes.any((e) => e.recipeId == recipeId);

  ActiveCookingSessionState copyWith({
    List<CookingRecipeEntry>? recipes,
    String? currentRecipeId,
    bool clearCurrentRecipe = false,
    bool? wasInCookingMode,
  }) {
    return ActiveCookingSessionState(
      recipes: recipes ?? this.recipes,
      currentRecipeId:
          clearCurrentRecipe ? null : (currentRecipeId ?? this.currentRecipeId),
      wasInCookingMode: wasInCookingMode ?? this.wasInCookingMode,
    );
  }
}

@Riverpod(keepAlive: true)
class ActiveCookingSession extends _$ActiveCookingSession {
  @override
  ActiveCookingSessionState build() => const ActiveCookingSessionState();

  void addRecipe(CookingRecipeEntry entry) {
    if (state.isRecipeActive(entry.recipeId)) return;
    final newRecipes = [...state.recipes, entry];
    state = state.copyWith(
      recipes: newRecipes,
      currentRecipeId: state.currentRecipeId ?? entry.recipeId,
      // Starting a session implies the user is actively cooking — default
      // the restored tab to cooking mode rather than overview.
      wasInCookingMode: state.wasInCookingMode || !state.isActive,
    );
  }

  void removeRecipe(String recipeId) {
    final newRecipes =
        state.recipes.where((e) => e.recipeId != recipeId).toList();
    String? newCurrent = state.currentRecipeId;
    if (newCurrent == recipeId) {
      newCurrent = newRecipes.isNotEmpty ? newRecipes.first.recipeId : null;
    }
    state = ActiveCookingSessionState(
      recipes: newRecipes,
      currentRecipeId: newCurrent,
    );
  }

  void setCurrentStep(String recipeId, int step) {
    final newRecipes = state.recipes.map((e) {
      if (e.recipeId == recipeId) return e.copyWith(currentStep: step);
      return e;
    }).toList();
    state = state.copyWith(recipes: newRecipes);
  }

  void setCurrentRecipe(String recipeId) {
    state = state.copyWith(currentRecipeId: recipeId);
  }

  void setWasInCookingMode(bool value) {
    if (state.wasInCookingMode == value) return;
    state = state.copyWith(wasInCookingMode: value);
  }

  void clearSession() {
    state = const ActiveCookingSessionState();
  }
}
