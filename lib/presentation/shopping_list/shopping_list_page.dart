import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/shopping_list/widgets/shopping_list_body.dart';
import 'package:meal_planner/services/providers/shopping_list_provider.dart';

@RoutePage()
class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(
        title: "Einkaufsliste",
        actionsButtons: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'remove_checked') {
                ref.read(shoppingListProvider.notifier).removeCheckedItems();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'remove_checked',
                child: Text('Abgehakte entfernen'),
              ),
            ],
          ),
        ],
      ),
      scaffoldBody: ShoppingListBody(),
    );
  }
}
