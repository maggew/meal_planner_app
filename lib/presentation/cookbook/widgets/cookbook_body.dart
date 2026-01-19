import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_search_results_list.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_searchbar.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_tabbar.dart';
import 'package:meal_planner/services/providers/recipe/recipe_search_provider.dart';

class CookbookBody extends ConsumerWidget {
  const CookbookBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSearching = ref.watch(isSearchActiveProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        CookbookSearchbar(),
        SizedBox(height: 20),
        if (isSearching) ...[
          Expanded(child: CookbookSearchResultsList()),
        ] else ...[
          CookbookTabbar(),
        ]
      ],
    );
  }
}
