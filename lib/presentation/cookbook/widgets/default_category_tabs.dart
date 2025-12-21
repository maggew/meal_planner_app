import 'package:flutter/material.dart';
import 'package:meal_planner/appstyle/app_icons.dart';

Tab categoryTab({
  required String text,
  required Icon iconWidget,
  TextAlign? textAlign,
  TextStyle? textStyle,
}) {
  return Tab(
    child: Center(
      child: Column(
        children: [
          SizedBox(height: 8),
          iconWidget,
          Text(
            text,
            textAlign: textAlign,
            style: textStyle,
          ),
          SizedBox(height: 8),
        ],
      ),
    ),
  );
}

List<Tab> DefaultCategoryTabs = [
  categoryTab(
    text: "Suppen",
    iconWidget: Icon(
      AppIcons.soup,
      size: 30,
    ),
  ),
  categoryTab(
    text: "Salate",
    iconWidget: Icon(
      AppIcons.salad,
      size: 30,
    ),
  ),
  categoryTab(
    text: "Saucen,\nDips",
    textAlign: TextAlign.center,
    textStyle: TextStyle(height: 0.9),
    iconWidget: Icon(
      AppIcons.soup,
      size: 30,
    ),
  ),
  categoryTab(
    text: "Haupt-\ngerichtee",
    textAlign: TextAlign.center,
    textStyle: TextStyle(height: 0.9),
    iconWidget: Icon(
      AppIcons.pizza,
      size: 30,
    ),
  ),
  categoryTab(
    text: "Desserts",
    iconWidget: Icon(
      AppIcons.ice_cream_cone,
      size: 30,
    ),
  ),
  categoryTab(
    text: "Gebäck",
    iconWidget: Icon(
      AppIcons.wedding_cake,
      size: 30,
    ),
  ),
  categoryTab(
    text: "Sonstiges",
    iconWidget: Icon(
      AppIcons.dish,
      size: 30,
    ),
  ),
  Tab(
    child: Center(
      child: Column(
        children: [
          SizedBox(height: 8),
          Image(
            image: AssetImage("assets/images/caticorn.png"),
            height: 40,
          ),
          SizedBox(height: 8),
        ],
      ),
    ),
  ),
];
