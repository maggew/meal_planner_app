import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_icons.dart';

@RoutePage()
class IconPreviewPage extends StatelessWidget {
  const IconPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = <MapEntry<String, IconData>>[
      const MapEntry('soup', AppIcons.soup),
      const MapEntry('dish', AppIcons.dish),
      const MapEntry('pizza', AppIcons.pizza),
      const MapEntry('ice_cream_cone', AppIcons.ice_cream_cone),
      const MapEntry('salad', AppIcons.salad),
      const MapEntry('wedding_cake', AppIcons.wedding_cake),
      const MapEntry('snowflake', AppIcons.snowflake),
      const MapEntry('cheese_burger', AppIcons.cheese_burger),
      const MapEntry('shopping_list', AppIcons.shopping_list),
      const MapEntry('trash_bin', AppIcons.trash_bin),
      const MapEntry('file', AppIcons.file),
      const MapEntry('upload', AppIcons.upload),
      const MapEntry('settings', AppIcons.settings),
      const MapEntry('recipe_book', AppIcons.recipe_book),
      const MapEntry('cookbook', AppIcons.cookbook),
      const MapEntry('plus_1', AppIcons.plus_1),
      const MapEntry('plus_2', AppIcons.plus_2),
      const MapEntry('calendar_1', AppIcons.calendar_1),
      const MapEntry('calendar_2', AppIcons.calendar_2),
      const MapEntry('cat_1', AppIcons.cat_1),
      const MapEntry('cat_2', AppIcons.cat_2),
      const MapEntry('cat_3', AppIcons.cat_3),
      const MapEntry('user', AppIcons.user),
      const MapEntry('login', AppIcons.login),
      const MapEntry('logout', AppIcons.logout),
      const MapEntry('group_1', AppIcons.group_1),
      const MapEntry('group_2', AppIcons.group_2),
      const MapEntry('group_3', AppIcons.group_3),
      const MapEntry('puzzle', AppIcons.puzzle),
      const MapEntry('unity', AppIcons.unity),
      const MapEntry('cheers', AppIcons.cheers),
      const MapEntry('handshake', AppIcons.handshake),
      const MapEntry('network', AppIcons.network),
      const MapEntry('join', AppIcons.join),
      const MapEntry('partnership', AppIcons.partnership),
      const MapEntry('add_friend', AppIcons.add_friend),
      const MapEntry('add', AppIcons.add),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Icon Preview')),
      body: GridView.count(
        crossAxisCount: 4,
        children: icons.map((entry) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(entry.value, size: 30),
              Text(entry.key, style: const TextStyle(fontSize: 10)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
