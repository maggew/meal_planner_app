import 'package:flutter/material.dart';

class CommonAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actionsButtons;
  final bool automaticallyImplyLeading;

  const CommonAppbar({
    super.key,
    required this.title,
    this.leading,
    this.actionsButtons,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 80,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: 0,
      title: Text(
        title,
        overflow: TextOverflow.fade,
      ),
      centerTitle: true,
      actions: actionsButtons,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
