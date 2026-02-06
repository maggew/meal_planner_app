import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/presentation/common/burger_menu/widgets/burger_menu_list_item.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';

List<Widget> getBurgerMenuItems(BuildContext context, WidgetRef ref) {
  return [
    BurgerMenuListItem(
      icon: AppIcons.calendar_1,
      label: 'Essensplan',
      onTap: () => context.router.push(const DetailedWeekplanRoute()),
    ),
    BurgerMenuListItem(
      icon: AppIcons.recipe_book,
      label: 'Kochbuch',
      onTap: () => context.router.push(const CookbookRoute()),
    ),
    BurgerMenuListItem(
      icon: AppIcons.shopping_list,
      label: "Einkaufsliste",
      onTap: () {},
    ),
    BurgerMenuListItem(
      icon: AppIcons.snowflake,
      label: 'Gefriertruhe',
      onTap: () => context.router.push(const RefrigeratorRoute()),
    ),
    // BurgerMenuListItem(
    //   icon: AppIcons.unity,
    //   label: "Meine Gruppen",
    //   onTap: () => context.router.push(const ShowUserGroupsRoute()),
    // ),
    BurgerMenuListItem(
      icon: AppIcons.cat_1,
      label: "Mein Profil",
      onTap: () {},
    ),
    BurgerMenuListItem(
      icon: AppIcons.logout,
      label: 'Logout',
      onTap: () => _handleLogout(context, ref),
    ),
  ];
}

Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
  final authController = ref.read(authControllerProvider.notifier);

  showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Ausloggen'),
      content: const Text('Möchtest du dich wirklich ausloggen?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            authController.logout();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Ausloggen'),
        ),
      ],
    ),
  );
}
