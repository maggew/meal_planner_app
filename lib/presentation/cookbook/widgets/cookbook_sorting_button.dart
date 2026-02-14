import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_sorting_button_item.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';

class CookbookSortingButton extends ConsumerWidget {
  const CookbookSortingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOption =
        ref.watch(userSettingsProvider.select((s) => s.recipeSortOption));

    return PopupMenuButton<RecipeSortOption>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sortierung',
      onSelected: (option) {
        ref.read(userSettingsProvider.notifier).updateRecipeSort(option);
      },
      itemBuilder: (context) {
        return [
          cookbookSortingButtonItem(
              option: RecipeSortOption.alphabetical,
              icon: Icons.sort_by_alpha,
              label: 'A-Z',
              current: sortOption),
          cookbookSortingButtonItem(
              option: RecipeSortOption.newest,
              icon: Icons.schedule,
              label: 'Neueste',
              current: sortOption),
          cookbookSortingButtonItem(
              option: RecipeSortOption.oldest,
              icon: Icons.schedule,
              label: 'Älteste',
              current: sortOption),
          cookbookSortingButtonItem(
              option: RecipeSortOption.mostCooked,
              icon: Icons.favorite,
              label: 'Beliebt',
              current: sortOption),
        ];
      },
    );
  }
}
