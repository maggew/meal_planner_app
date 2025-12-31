import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/domain/repositories/auth_repository.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';
import 'package:meal_planner/services/providers/current_group_provider.dart';

class BurgerMenu extends ConsumerWidget {
  final double width;
  const BurgerMenu({
    super.key,
    required this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(currentGroupProvider);
    final authRepository = ref.watch(authRepositoryProvider);

    return groupAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (group) {
        final imageUrl = group?.imageUrl;
        final image = (imageUrl == null)
            ? Image.asset(
                'assets/images/group_pic.jpg',
                height: 200,
                width: width * MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              )
            : CachedNetworkImage(
                height: 200,
                width: width * MediaQuery.of(context).size.width,
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              );

        return SizedBox(
          width: width * MediaQuery.of(context).size.width,
          child: Drawer(
            backgroundColor: Colors.lightGreen[100],
            elevation: 20,
            child: SingleChildScrollView(
              child: Column(
                children: getBurgerMenuItems(
                  context: context,
                  group: group,
                  groupImage: image,
                  authRepository: authRepository,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> getBurgerMenuItems({
    required context,
    required dynamic group,
    required dynamic groupImage,
    required AuthRepository authRepository,
  }) {
    return [
      SizedBox(height: MediaQuery.of(context).padding.top),
      Stack(
        children: [
          Opacity(opacity: 0.8, child: groupImage),
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.keyboard_arrow_left),
              onPressed: () => AutoRouter.of(context).pop(),
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            group['name'],
            style: const TextStyle(fontSize: 27.5),
          ),
        ),
      ),
      const SizedBox(height: 30),
      _menuItem(
        context,
        icon: AppIcons.calendar_1,
        label: 'Essensplan',
        onTap: () => AutoRouter.of(context).push(const DetailedWeekplanRoute()),
      ),
      _menuItem(
        context,
        icon: AppIcons.recipe_book,
        label: 'Kochbuch',
        onTap: () => AutoRouter.of(context).push(const CookbookRoute()),
      ),
      _menuItem(context,
          icon: AppIcons.shopping_list, label: "Einkaufsliste", onTap: () {}),
      _menuItem(
        context,
        icon: AppIcons.snowflake,
        label: 'Gefriertruhe',
        onTap: () => AutoRouter.of(context).push(const RefrigeratorRoute()),
      ),
      _menuItem(
        context,
        icon: AppIcons.unity,
        label: "Meine Gruppen",
        onTap: () => AutoRouter.of(context).push(const ShowUserGroupsRoute()),
      ),
      _menuItem(context,
          icon: AppIcons.cat_1, label: "Mein Profil", onTap: () {}),
      _menuItem(
        context,
        icon: AppIcons.logout,
        label: 'Logout',
        onTap: () async {
          //TODO: hier noch ein popup, ob man sich sicher ist!
          await authRepository.signOut();
          AutoRouter.of(context).pushAll([const LoginRoute()]);
        },
      ),
    ];
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        SizedBox(
          width: width * MediaQuery.of(context).size.width,
          child: TextButton(
            onPressed: onTap,
            child: Row(
              children: [
                const SizedBox(width: 10),
                Icon(icon),
                const SizedBox(width: 10),
                Text(label),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
