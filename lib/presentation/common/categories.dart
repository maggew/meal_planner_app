import 'package:flutter/material.dart';
import 'package:meal_planner/appstyle/app_icons.dart';

List<String> categoryNames = [
  "Suppen",
  "Salate",
  "Saucen, Dips",
  "Hauptgerichte",
  "Desserts",
  "Gebäck",
  "Sonstiges",
];

IconData getCategoryIconData(String categoryName) {
  switch (categoryName) {
    case "Suppen":
      return AppIcons.soup;
    case "Salate":
      return AppIcons.salad;
    case "Saucen, Dips":
      return AppIcons.soup;
    case "Hauptgerichte":
      return AppIcons.pizza;
    case "Desserts":
      return AppIcons.ice_cream_cone;
    case "Gebäck":
      return AppIcons.wedding_cake;
    case "Sonstiges":
      return AppIcons.dish;
    default:
      return AppIcons.settings;
  }
}
