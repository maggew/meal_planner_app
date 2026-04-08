import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/sync_status_indicator.dart';

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
    // Sync indicator is global: it auto-injects itself into every page's
    // AppBar and stays invisible while sync is `idle`/`ok`. Page-level
    // `actionsButtons` render to its right.
    final actions = <Widget>[
      const SyncStatusIndicator(),
      ...?actionsButtons,
    ];

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
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
