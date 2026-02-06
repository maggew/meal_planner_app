import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_icons.dart';

class CommonAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool hasActionButton;
  final Function()? onActionPressed;
  const CommonAppbar(
      {super.key,
      required this.title,
      required this.hasActionButton,
      this.onActionPressed})
      : assert(!hasActionButton || onActionPressed != null,
            'onActionPressed is required if hasActionButton is true!');

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 80,
      leading: Builder(
        builder: (context) {
          return IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.transparent),
            icon: Icon(Icons.menu), //FaIcon(FontAwesomeIcons.bars),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      foregroundColor: Colors.black,
      elevation: 0,
      title: Text(
        title,
        style: Theme.of(context).textTheme.displaySmall,
      ),
      centerTitle: true,
      actions: hasActionButton
          ? [
              IconButton(
                onPressed: onActionPressed!,
                icon: Icon(
                  AppIcons.plus_1,
                  size: 35,
                ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
