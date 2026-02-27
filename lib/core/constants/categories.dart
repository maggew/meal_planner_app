import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_icons.dart';

List<String> categoryNames = [
  "Suppen",
  "Salate",
  "Saucen, Dips",
  "Hauptgerichte",
  "Desserts",
  "Gebäck",
  "Sonstiges",
];

final Map<String, String> mapGermanCategoryToEnglishCategory = {
  "Suppen": "soups",
  "Salate": "salads",
  "Saucen, Dips": "sauces_dips",
  "Hauptgerichte": "mainDishes",
  "Desserts": "desserts",
  "Gebäck": "bakery",
  "Sonstiges": "others",
};

final Map<String, String> mapEnglishCategoryToGermanCategory = {
  for (final entry in mapGermanCategoryToEnglishCategory.entries)
    entry.value: entry.key
};

String getCategoryNameEnglish(String categoryName) {
  switch (categoryName) {
    case "Suppen":
      return "soups";
    case "Salate":
      return "salads";
    case "Saucen, Dips":
      return "sauces_dips";
    case "Hauptgerichte":
      return "mainDishes";
    case "Desserts":
      return "desserts";
    case "Gebäck":
      return "bakery";
    case "Sonstiges":
      return "others";
    default:
      return "error";
  }
}

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
