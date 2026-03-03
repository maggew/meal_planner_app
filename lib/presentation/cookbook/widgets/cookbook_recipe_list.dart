// lib/presentation/cookbook/widgets/cookbook_recipe_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_recipe_list_item.dart';
import 'package:meal_planner/services/providers/recipe/recipe_pagination_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_search_provider.dart';

class CookbookRecipeList extends ConsumerStatefulWidget {
  final String categoryId;
  final List<String> allCategories;
  final bool tabsLeft;

  const CookbookRecipeList({
    required this.categoryId,
    required this.allCategories,
    required this.tabsLeft,
    super.key,
  });

  @override
  ConsumerState<CookbookRecipeList> createState() => _CookbookRecipeListState();
}

class _CookbookRecipeListState extends ConsumerState<CookbookRecipeList> {
  final ScrollController _scrollController = ScrollController();
  late final String categoryId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    categoryId = widget.categoryId;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(recipesPaginationProvider(categoryId).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginationState = ref.watch(recipesPaginationProvider(categoryId));
    final isSearching = ref.watch(isSearchActiveProvider);

    final recipes = ref.watch(
      filteredRecipesProvider(
        category: categoryId,
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
          ref.read(recipesPaginationProvider(categoryId).notifier).refresh();
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
          : "Noch keine Rezepte in\ndieser Kategorie";
      final icon = isSearching
          ? Icons.search_off_rounded
          : Icons.restaurant_menu_rounded;
      return _alwaysScrollableListView(children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Icon(
          icon,
          size: 48,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
        ),
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
                      .read(recipesPaginationProvider(categoryId).notifier)
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
