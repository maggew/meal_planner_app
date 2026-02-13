import 'package:flutter/material.dart';

class CookbookCategoryTab extends Tab {
  final String name;
  final Icon iconWidget;
  CookbookCategoryTab({
    super.key,
    required this.name,
    required this.iconWidget,
  }) : super(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 8),
                iconWidget,
                Text(_editCategoryNameForCookbookTabbar(name)),
                SizedBox(height: 8),
              ],
            ),
          ),
        );
}

String _editCategoryNameForCookbookTabbar(String name) {
  if (name == "Saucen, Dips") {
    return "Saucen,\nDips";
  } else if (name == "Hauptgerichte") {
    return "Haupt-\ngerichte";
  }
  return name;
}
