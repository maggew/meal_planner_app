import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';

PopupMenuItem<RecipeSortOption> cookbookSortingButtonItem({
  required RecipeSortOption option,
  required IconData icon,
  required String label,
  required RecipeSortOption current,
}) {
  return PopupMenuItem(
    value: option,
    child: ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: current == option ? const Icon(Icons.check, size: 18) : null,
      dense: true,
    ),
  );
}

