import 'package:flutter/material.dart';

extension TextThemeExtensions on TextTheme {
  TextStyle? get bodyLargeEmphasis =>
      bodyLarge?.copyWith(fontWeight: FontWeight.w700);
  TextStyle? get bodyMediumEmphasis =>
      bodyMedium?.copyWith(fontWeight: FontWeight.w700);
  TextStyle? get bodySmallEmphasis =>
      bodySmall?.copyWith(fontWeight: FontWeight.w700);
}
