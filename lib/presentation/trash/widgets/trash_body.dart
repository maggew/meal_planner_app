import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/presentation/trash/widgets/trash_recipe_list_item.dart';
import 'package:meal_planner/services/providers/recipe/trash_provider.dart';

class TrashBody extends ConsumerStatefulWidget {
  const TrashBody({super.key});

  @override
  ConsumerState<TrashBody> createState() => _TrashBodyState();
}

class _TrashBodyState extends ConsumerState<TrashBody> {
  final _scrollController = ScrollController();

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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(trashProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trashProvider);

    if (state.recipes.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.recipes.isEmpty && !state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.trash_bin,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Papierkorb ist leer',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(trashProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.recipes.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.recipes.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return TrashRecipeListItem(recipe: state.recipes[index]);
        },
      ),
    );
  }
}
