import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_icons.dart';

class ShowRecipeAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String recipeName;
  const ShowRecipeAppbar({super.key, required this.recipeName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.black,
          ),
          onPressed: () {
            AutoRouter.of(context).pop();
          }),
      centerTitle: true,
      title: FittedBox(
          child: Text(
        recipeName,
        style: Theme.of(context).textTheme.displayMedium,
      )),
      actions: [
        IconButton(
          onPressed: () {
            //TODO: open editor for recipe
          },
          icon: Icon(
            Icons.edit_outlined,
            color: Colors.black,
            size: 20,
          ),
        ),
        IconButton(
          onPressed: () {
            //TODO: delete recipe from cookbook
          },
          icon: Icon(
            AppIcons.trash_bin,
            color: Colors.black,
            size: 20,
          ),
        ),
        SizedBox(width: 5),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
