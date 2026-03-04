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

/// Icons, die im Icon-Picker zur Auswahl stehen (Name → IconData)
const Map<String, IconData> categoryIconOptions = {
  'dish': AppIcons.dish,
  'soup': AppIcons.soup,
  'salad': AppIcons.salad,
  'pizza': AppIcons.pizza,
  'ice_cream_cone': AppIcons.ice_cream_cone,
  'wedding_cake': AppIcons.wedding_cake,
  'cheese_burger': AppIcons.cheese_burger,
  'snowflake': AppIcons.snowflake,
};

/// Gibt das Icon für eine Kategorie zurück.
/// Wenn [iconName] gesetzt ist, wird es direkt verwendet.
/// Fallback: Name-basierte Zuordnung für Default-Kategorien.
IconData getCategoryIconData(String categoryName, {String? iconName}) {
  if (iconName != null && categoryIconOptions.containsKey(iconName)) {
    return categoryIconOptions[iconName]!;
  }
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
