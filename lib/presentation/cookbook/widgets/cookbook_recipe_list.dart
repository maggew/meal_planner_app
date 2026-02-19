// lib/presentation/cookbook/widgets/cookbook_recipe_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_recipe_list_item.dart';
import 'package:meal_planner/services/providers/recipe/recipe_pagination_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_search_provider.dart';

class CookbookRecipeList extends ConsumerStatefulWidget {
  final String category;
  final List<String> allCategories;
  final bool tabsLeft;

  const CookbookRecipeList({
    required this.category,
    required this.allCategories,
    required this.tabsLeft,
    super.key,
  });

  @override
  ConsumerState<CookbookRecipeList> createState() => _CookbookRecipeListState();
}

class _CookbookRecipeListState extends ConsumerState<CookbookRecipeList> {
  final ScrollController _scrollController = ScrollController();
  late final String category;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    category = widget.category.toLowerCase();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(recipesPaginationProvider(category).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginationState = ref.watch(recipesPaginationProvider(category));
    final isSearching = ref.watch(isSearchActiveProvider);

    final recipes = ref.watch(
      filteredRecipesProvider(
        category: category,
        allCategories: widget.allCategories,
      ),
    );
    final margin = widget.tabsLeft
        ? EdgeInsets.only(left: 10)
        : EdgeInsets.only(right: 10);
    final containerBorderRadius = widget.tabsLeft
        ? BorderRadius.only(topLeft: Radius.circular(8))
        : BorderRadius.only(topRight: Radius.circular(8));

    return Container(
      margin: margin,
      padding: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: containerBorderRadius,
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.read(recipesPaginationProvider(category).notifier).refresh();
        },
        child: _buildContent(
          recipes: recipes,
          isLoading: paginationState.isLoading,
          hasMore: paginationState.hasMore,
          error: paginationState.error,
          isSearching: isSearching,
        ),
      ),
    );
  }

  Widget _buildContent({
    required List<Recipe> recipes,
    required bool isLoading,
    required bool hasMore,
    required String? error,
    required bool isSearching,
  }) {
    if (recipes.isEmpty && isLoading) {
      return _alwaysScrollableListView(children: [
        SizedBox(height: 100),
        Center(child: CircularProgressIndicator()),
      ]);
    } else if (recipes.isEmpty && !isLoading) {
      final message = isSearching
          ? "Keine Rezepte gefunden"
          : "Keine Rezepte in dieser Kategorie!";
      return _alwaysScrollableListView(children: [
        SizedBox(height: 100),
        Center(child: Text(message)),
      ]);
    } else if (error != null && recipes.isEmpty) {
      return _alwaysScrollableListView(children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(recipesPaginationProvider(category).notifier)
                      .refresh();
                },
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ]);
    }

    // Bei aktiver Suche keine Pagination anzeigen
    final showLoadingIndicator = !isSearching && hasMore;

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: recipes.length + (showLoadingIndicator ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == recipes.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(color: Colors.green),
            ),
          );
        }
        return CookbookRecipeListItem(recipe: recipes[index]);
      },
    );
  }
}

ListView _alwaysScrollableListView({required List<Widget> children}) {
  return ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: children,
  );
}
