import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/presentation/refrigerator_screen.dart';
import 'package:meal_planner/services/auth.dart';
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
    final auth = Auth();

    return groupAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (group) {
        final imagePath = group['icon'] as String? ?? '';
        final groupImage = imagePath.isEmpty
            ? Image.asset(
                'assets/images/group_pic.jpg',
                height: 200,
                width: width * MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              )
            : CachedNetworkImage(
                height: 200,
                width: width * MediaQuery.of(context).size.width,
                imageUrl: imagePath,
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
                  groupImage: groupImage,
                  auth: auth,
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
    required Auth auth,
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
              onPressed: () => Navigator.of(context).pop(),
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
      _menuItem(context,
          icon: AppIcons.calendar_1, label: 'Essensplan', onTap: () {}),
      _menuItem(
        context,
        icon: AppIcons.recipe_book,
        label: 'Kochbuch',
        onTap: () => Navigator.pushReplacementNamed(context, '/cookbook'),
      ),
      _menuItem(context,
          icon: AppIcons.shopping_list, label: "Einkaufsliste", onTap: () {}),
      _menuItem(
        context,
        icon: AppIcons.snowflake,
        label: 'Gefriertruhe',
        onTap: () => Navigator.pushNamed(context, RefrigeratorScreen.route),
      ),
      _menuItem(context,
          icon: AppIcons.unity,
          label: "Meine Gruppen",
          onTap: () =>
              Navigator.pushReplacementNamed(context, 'show_userGroups')),
      _menuItem(context,
          icon: AppIcons.cat_1, label: "Mein Profil", onTap: () {}),
      _menuItem(
        context,
        icon: AppIcons.logout,
        label: 'Logout',
        onTap: () async {
          await auth.signOut();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (r) => false,
          );
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
