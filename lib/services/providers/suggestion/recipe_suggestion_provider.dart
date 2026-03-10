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

      // 2. Load meal plan entries in a ±14-day window around today
      final today = DateTime.now();
      final fromDate = today.subtract(const Duration(days: 14));
      final toDate = today.add(const Duration(days: 14));
      final rangeEntries = await mealPlanDao.getEntriesInRange(
        groupId,
        _formatDate(fromDate),
        _formatDate(toDate),
      );

      // 3. Build lastCookedMap: recipeId → days to nearest occurrence (past or future)
      final Map<String, int> lastCookedMap = {};
      for (final entry in rangeEntries) {
        if (entry.recipeId.isEmpty) continue;
        final entryDate = DateTime.tryParse(entry.date);
        if (entryDate == null) continue;
        final daysAway = today.difference(entryDate).inDays.abs();
        final existing = lastCookedMap[entry.recipeId];
        if (existing == null || daysAway < existing) {
          lastCookedMap[entry.recipeId] = daysAway;
        }
      }

      // 4. Collect carb tags from entries within ±3 days of today
      final recentCarbTags = <String>[];
      for (final entry in rangeEntries) {
        if (entry.recipeId.isEmpty) continue;
        final entryDate = DateTime.tryParse(entry.date);
        if (entryDate == null) continue;
        if (today.difference(entryDate).inDays.abs() > 3) continue;
        final recipe =
            recipes.where((r) => r.id == entry.recipeId).firstOrNull;
        if (recipe != null) {
          recentCarbTags.addAll(recipe.carbTags);
        }
      }

      // 5. Read algorithm weights from group settings
      final settings = ref.read(sessionProvider).group?.settings;
      final rotationWeight = settings?.rotationWeight ?? 3;
      final carbVarietyWeight = settings?.carbVarietyWeight ?? 2;

      // 6. Run suggestion algorithm
      final results = RecipeSuggestionService.suggest(
        recipes: recipes,
        inputIngredients: ingredients,
        lastCookedMap: lastCookedMap,
        recentCarbTags: recentCarbTags,
        rotationWeight: rotationWeight,
        carbVarietyWeight: carbVarietyWeight,
      );

      state = state.copyWith(suggestions: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

final recipeSuggestionProvider =
    NotifierProvider<RecipeSuggestionNotifier, RecipeSuggestionState>(
  RecipeSuggestionNotifier.new,
);
