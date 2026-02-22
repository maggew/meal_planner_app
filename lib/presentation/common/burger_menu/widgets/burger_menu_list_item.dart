import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class BurgerMenuListItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const BurgerMenuListItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(label),
          leading: Icon(icon),
          onTap: () {
            context.router.pop();
            onTap();
          },
        ),
        const Divider(),
      ],
    );
  }
}
