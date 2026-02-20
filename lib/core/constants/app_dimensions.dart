import 'package:flutter/material.dart';

class AppDimensions {
  static const double burgerMenuWidthPercentage = 0.7;
  static const double borderRadius = 12.0;
  static const borderRadiusAll =
      BorderRadius.all(Radius.circular(borderRadius));

  static const double screenMargin = 20.0;
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: screenMargin);
  static const Duration animationDuration = Duration(milliseconds: 200);
}
