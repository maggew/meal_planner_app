import 'package:flutter/material.dart';

extension TextThemeExtensions on TextTheme {
  TextStyle? get bodyLargeEmphasis =>
      bodyLarge?.copyWith(fontWeight: FontWeight.w700);
  TextStyle? get bodyMediumEmphasis =>
      bodyMedium?.copyWith(fontWeight: FontWeight.w700);
  TextStyle? get bodySmallEmphasis =>
      bodySmall?.copyWith(fontWeight: FontWeight.w700);

  TextStyle? get bodyLargeClickable => bodyLarge?.copyWith(
        color: Colors.blue[700],
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        decorationColor: Colors.blue[700],
      );
}
