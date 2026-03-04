import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/database/converters/recipe_cache_converter.dart';
import 'package:meal_planner/domain/entities/recipe_suggestion.dart';
import 'package:meal_planner/domain/services/recipe_suggestion_service.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class RecipeSuggestionState {
  final List<RecipeSuggestion> suggestions;
  final bool isLoading;
  final String? error;

  const RecipeSuggestionState({
    this.suggestions = const [],
    this.isLoading = false,
    this.error,
  });

  RecipeSuggestionState copyWith({
    List<RecipeSuggestion>? suggestions,
    bool? isLoading,
    String? error,
  }) {
    return RecipeSuggestionState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RecipeSuggestionNotifier extends Notifier<RecipeSuggestionState> {
  @override
  RecipeSuggestionState build() => const RecipeSuggestionState();

  Future<void> suggest(List<String> ingredients) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final groupId = ref.read(sessionProvider).groupId ?? '';
      final recipeDao = ref.read(recipeCacheDaoProvider);
      final mealPlanDao = ref.read(mealPlanDaoProvider);

      // 1. Load all recipes from cache
      final localRecipes = await recipeDao.watchRecipesByGroup(groupId).first;
      final recipes =
          localRecipes.map((r) => RecipeCacheConverter.toRecipe(r)).toList();

      // 2. Load recent 14-day meal plan entries
      final recentEntries = await mealPlanDao.getRecentEntries(groupId, 14);

      // 3. Build lastCookedMap: recipeId → days since last cooked
      final today = DateTime.now();
      final Map<String, int> lastCookedMap = {};
      for (final entry in recentEntries) {
        if (entry.recipeId.isEmpty) continue;
        final entryDate = DateTime.tryParse(entry.date);
        if (entryDate == null) continue;
        final daysAgo = today.difference(entryDate).inDays;
        final existing = lastCookedMap[entry.recipeId];
        if (existing == null || daysAgo < existing) {
          lastCookedMap[entry.recipeId] = daysAgo;
        }
      }

      // 4. Collect recent carb tags (last 3 days)
      final threeDaysAgo = today.subtract(const Duration(days: 3));
      final recentCarbTags = <String>[];
      for (final entry in recentEntries) {
        if (entry.recipeId.isEmpty) continue;
        final entryDate = DateTime.tryParse(entry.date);
        if (entryDate == null || entryDate.isBefore(threeDaysAgo)) continue;
        final recipe = recipes.where((r) => r.id == entry.recipeId).firstOrNull;
        if (recipe != null) {
          recentCarbTags.addAll(recipe.carbTags);
        }
      }

      // 5. Run suggestion algorithm
      final results = RecipeSuggestionService.suggest(
        recipes: recipes,
        inputIngredients: ingredients,
        lastCookedMap: lastCookedMap,
        recentCarbTags: recentCarbTags,
      );

      state = state.copyWith(suggestions: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final recipeSuggestionProvider =
    NotifierProvider<RecipeSuggestionNotifier, RecipeSuggestionState>(
  RecipeSuggestionNotifier.new,
);
