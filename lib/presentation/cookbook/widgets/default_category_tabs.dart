import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/categories.dart';

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

List<Tab> getDefaultCategoryTabs() {
  List<Tab> out = [];
  for (String name in categoryNames) {
    out.add(
      categoryTab(
        text: _editCategoryNameForCookbookTabbar(name),
        iconWidget: Icon(
          getCategoryIconData(name),
          size: 30,
        ),
      ),
    );
  }
  out.add(
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
  );

  return out;
}

String _editCategoryNameForCookbookTabbar(String name) {
  if (name == "Saucen, Dips") {
    return "Saucen,\nDips";
  } else if (name == "Hauptgerichte") {
    return "Haupt-\ngerichte";
  }
  return name;
}
