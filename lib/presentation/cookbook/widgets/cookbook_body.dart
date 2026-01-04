import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_searchbar.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_tabbar.dart';

class CookbookBody extends StatelessWidget {
  const CookbookBody({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _searchbarController = TextEditingController();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        CookbookSearchbar(searchbarController: _searchbarController),
        SizedBox(height: 20),
        CookbookTabbar(),
      ],
    );
  }
}
