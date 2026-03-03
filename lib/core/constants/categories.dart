import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_icons.dart';

/// Default-Kategorien für neue Gruppen (lowercase, so wie in Supabase gespeichert)
const List<String> defaultCategoryNames = [
  "suppen",
  "salate",
  "saucen, dips",
  "hauptgerichte",
  "desserts",
  "gebäck",
  "sonstiges",
];

IconData getCategoryIconData(String categoryName) {
  switch (categoryName.toLowerCase()) {
    case "suppen":
      return AppIcons.soup;
    case "salate":
      return AppIcons.salad;
    case "saucen, dips":
      return AppIcons.soup;
    case "hauptgerichte":
      return AppIcons.pizza;
    case "desserts":
      return AppIcons.ice_cream_cone;
    case "gebäck":
      return AppIcons.wedding_cake;
    case "sonstiges":
      return AppIcons.dish;
    default:
      return AppIcons.dish;
  }
}
