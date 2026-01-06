import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_recipe_list_item.dart';
import 'package:meal_planner/services/providers/recipe/recipe_pagination_provider.dart';

class CookbookRecipeList extends ConsumerStatefulWidget {
  final String category;

  const CookbookRecipeList({
    required this.category,
    super.key,
  });

  @override
  ConsumerState<CookbookRecipeList> createState() => _CookbookRecipeListState();
}

class _CookbookRecipeListState extends ConsumerState<CookbookRecipeList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Wenn 200px vor dem Ende -> lade mehr
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(recipesPaginationProvider(widget.category).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginationState =
        ref.watch(recipesPaginationProvider(widget.category));
    print("übergebene category: ${widget.category}");

    return Container(
      color: Colors.lightGreen[100],
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.only(top: 5, left: 5),
      child: RefreshIndicator(
        onRefresh: () async {
          print('📱 WIDGET: RefreshIndicator triggered');
          ref
              .read(recipesPaginationProvider(widget.category).notifier)
              .refresh();
        },
        child: _buildContent(state: paginationState),
      ),
    );
  }

  Widget _buildContent({required RecipesPaginationState state}) {
    if (state.recipes.isEmpty && state.isLoading) {
      return const CircularProgressIndicator();
    } else if (state.recipes.isEmpty && !state.isLoading) {
      return const Center(
        child: Text("Keine Rezepte in dieser Kategorie!"),
      );
    } else if (state.error != null && state.recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(recipesPaginationProvider(widget.category).notifier)
                    .refresh();
              },
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.recipes.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading Indicator am Ende der Liste
        if (index == state.recipes.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(color: Colors.green),
            ),
          );
        }

        return CookbookRecipeListItem(recipe: state.recipes[index]);
      },
    );
  }
}
