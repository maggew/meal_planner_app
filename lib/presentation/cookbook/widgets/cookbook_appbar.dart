import 'package:flutter/material.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_add_recipe.dart';

class CookbookAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CookbookAppbar({super.key});

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
        "Kochbuch",
        style: Theme.of(context).textTheme.displayMedium,
      ),
      centerTitle: true,
      actions: [
        Container(
          height: 40,
          width: 40,
          child: FloatingActionButton(
            onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => CookbookAddRecipe()),
            backgroundColor: Colors.lightGreen[100],
            child: Icon(
              AppIcons.plus_1,
              size: 35,
              color: Colors.black,
            ),
          ),
        ),
        //SizedBox(width: 15),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
