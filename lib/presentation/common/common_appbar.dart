import 'package:flutter/material.dart';

class CommonAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actionsButtons;
  const CommonAppbar({
    super.key,
    required this.title,
    this.leading,
    this.actionsButtons,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 80,
      leading: leading != null
          ? leading
          : Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(Icons.menu), //FaIcon(FontAwesomeIcons.bars),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
      elevation: 0,
      title: Text(title),
      centerTitle: true,
      actions: actionsButtons,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
