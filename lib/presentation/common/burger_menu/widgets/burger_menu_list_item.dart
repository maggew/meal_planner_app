import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BurgerMenuListItem extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          title: Text(label),
          leading: Icon(icon),
          onTap: () {
            Navigator.of(context).pop();
            onTap();
          },
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
