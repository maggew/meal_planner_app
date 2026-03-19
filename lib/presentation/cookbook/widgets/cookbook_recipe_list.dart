// lib/presentation/cookbook/widgets/cookbook_recipe_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/common/native_ad_widget.dart';
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

class _CookbookRecipeListState extends ConsumerState<CookbookRecipeList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
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
    super.build(context);
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.read(recipesPaginationProvider(categoryId).notifier).refresh();
            },
            child: _buildContent(
              recipes: recipes,
              isLoading: paginationState.isLoading,
              hasMore: paginationState.hasMore,
              error: paginationState.error,
              isSearching: isSearching,
              availableHeight: constraints.maxHeight,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent({
    required List<Recipe> recipes,
    required bool isLoading,
    required bool hasMore,
    required String? error,
    required bool isSearching,
    required double availableHeight,
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: NativeAdWidget(height: 100),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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

    // Ad frequency: every 3 recipes on small lists, every 4 on larger
    final adInterval = availableHeight < 500 ? 3 : 4;

    // Few recipes (<adInterval): just append 1 ad at the end
    // Otherwise: insert an ad after every adInterval-th recipe
    final adCount = recipes.length < adInterval
        ? 1
        : (recipes.length ~/ adInterval);
    final trailingAd = recipes.length < adInterval;
    final totalItems =
        recipes.length + adCount + (showLoadingIndicator ? 1 : 0);
    final groupSize = adInterval + 1; // recipes + 1 ad slot

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // Loading indicator at the end
        if (index == totalItems - 1 && showLoadingIndicator) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(color: Colors.green),
            ),
          );
        }

        // Few recipes: all recipes first, then 1 trailing ad
        if (trailingAd) {
          if (index < recipes.length) {
            return CookbookRecipeListItem(recipe: recipes[index]);
          }
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: NativeAdWidget(height: 100),
          );
        }

        // Ad slot: after every adInterval-th recipe
        final adsBefore = index ~/ groupSize;
        final effectiveAdsBefore =
            adsBefore > adCount ? adCount : adsBefore;
        final recipeIndex = index - effectiveAdsBefore;

        if (index >= adInterval &&
            (index - adInterval) % groupSize == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: NativeAdWidget(height: 100),
          );
        }

        if (recipeIndex >= recipes.length) {
          return const SizedBox.shrink();
        }

        return CookbookRecipeListItem(recipe: recipes[recipeIndex]);
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
