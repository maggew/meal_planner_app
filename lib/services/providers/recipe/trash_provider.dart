import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'trash_provider.g.dart';

const int _trashPageSize = 25;

class TrashState {
  final List<Recipe> recipes;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const TrashState({
    this.recipes = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  TrashState copyWith({
    List<Recipe>? recipes,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return TrashState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

@riverpod
class Trash extends _$Trash {
  @override
  TrashState build() {
    Future.microtask(() => loadMore());
    return const TrashState();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);
    List<Recipe> newRecipes = [];
    String? error;
    bool? hasMore;

    try {
      final repo = ref.read(trashRepositoryProvider);
      newRecipes = await repo.getDeletedRecipes(
        offset: state.recipes.length,
        limit: _trashPageSize,
      );
      hasMore = newRecipes.length == _trashPageSize;
    } catch (e, st) {
      debugPrint('Trash load error: $e\n$st');
      error = e.toString();
    } finally {
      state = state.copyWith(
        recipes: [...state.recipes, ...newRecipes],
        isLoading: false,
        hasMore: hasMore ?? state.hasMore,
        error: error,
      );
    }
  }

  Future<void> refresh() async {
    state = const TrashState(isLoading: true);
    try {
      final repo = ref.read(trashRepositoryProvider);
      final recipes = await repo.getDeletedRecipes(
        offset: 0,
        limit: _trashPageSize,
      );
      state = TrashState(
        recipes: recipes,
        hasMore: recipes.length == _trashPageSize,
      );
    } catch (e) {
      state = TrashState(error: e.toString());
    }
  }

  Future<void> restoreRecipe(String recipeId) async {
    try {
      await ref.read(trashRepositoryProvider).restoreRecipe(recipeId);
      state = state.copyWith(
        recipes: state.recipes.where((r) => r.id != recipeId).toList(),
      );
    } catch (e) {
      debugPrint('Restore error: $e');
    }
  }

  Future<void> hardDeleteRecipe(String recipeId) async {
    try {
      await ref.read(trashRepositoryProvider).hardDeleteRecipe(recipeId);
      state = state.copyWith(
        recipes: state.recipes.where((r) => r.id != recipeId).toList(),
      );
    } catch (e) {
      debugPrint('Hard delete error: $e');
    }
  }
}
