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
      toolbarHeight: 80,
      leading: Builder(
        builder: (context) {
          return IconButton(
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
        style: Theme.of(context).textTheme.displayMedium,
      ),
      centerTitle: true,
      actions: hasActionButton
          ? [
              Container(
                height: 40,
                width: 40,
                child: FloatingActionButton(
                  onPressed: onActionPressed!,
                  backgroundColor: Colors.lightGreen[100],
                  child: Icon(
                    AppIcons.plus_1,
                    size: 35,
                    color: Colors.black,
                  ),
                ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
