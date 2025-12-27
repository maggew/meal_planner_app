import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class AddRecipeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const AddRecipeAppbar({super.key});

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
      title: FittedBox(
          child: Text(
        "Neues Rezept erstellen",
        style: Theme.of(context).textTheme.displayMedium,
      )),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
