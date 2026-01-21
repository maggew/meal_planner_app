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
    final isSearching = ref.watch(isSearchActiveProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        CookbookSearchbar(),
        SizedBox(height: 20),
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: isSearching
                ? CookbookSearchResultsList(key: ValueKey('search'))
                : CookbookTabbar(key: ValueKey('tabbar')),
          ),
        ),
      ],
    );
  }
}
