import 'package:flutter/material.dart';

class CookbookCategoryTab extends Tab {
  final String name;
  final Icon iconWidget;
  CookbookCategoryTab({
    super.key,
    required this.name,
    required this.iconWidget,
  }) : super(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                const SizedBox(height: 2),
                Text(
                  _editCategoryNameForCookbookTabbar(name),
                  style: const TextStyle(fontSize: 9),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
}

String _editCategoryNameForCookbookTabbar(String name) {
  if (name == "Hauptgerichte") return "Hauptger.";
  if (name == "Saucen, Dips") return "Saucen";
  return name;
}
