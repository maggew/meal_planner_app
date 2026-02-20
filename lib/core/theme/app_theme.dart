import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(brightness: Brightness.light);
  static ThemeData get dark => _buildTheme(brightness: Brightness.dark);

  static ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    // Farben
    final primary = isDark ? Colors.green[300]! : Colors.green[400]!;
    final onPrimary = isDark ? Colors.black : Colors.white;
    final primaryContainer = isDark ? Colors.green[900]! : Colors.green[100]!;
    final secondary = isDark ? Colors.orange[600]! : Colors.orange[400]!;
    final onSecondary = isDark ? Colors.black : Colors.white;
    final secondaryContainer =
        isDark ? const Color(0xFF4A2800) : Colors.orange[100]!;
    final onSecondaryContainer = isDark ? Colors.white : Colors.orange[900]!;
    final error = isDark ? Colors.red[300]! : Colors.red[400]!;
    final onError = Colors.white;
    final surface = isDark ? Colors.grey[900]! : Colors.white;
    final onSurface = isDark ? Colors.white : Colors.black;
    final surfaceContainer = isDark ? Colors.grey[850]! : Colors.grey[100]!;

    final _colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      error: error,
      onError: onError,
      surface: surface,
      onSurface: onSurface,
      surfaceContainer: surfaceContainer,
    );

    // Text Styles
    final titleLarge = TextStyle(
      fontFamily: GoogleFonts.quicksand().fontFamily,
      fontSize: 25,
      fontWeight: FontWeight.w700,
      color: onSurface,
    );
    final titleMedium = titleLarge.copyWith(fontSize: 20);
    final titleSmall = titleLarge.copyWith(fontSize: 17);

    final bodyLarge = TextStyle(
      fontFamily: GoogleFonts.quicksand().fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: onSurface,
    );
    final bodyMedium = bodyLarge.copyWith(fontSize: 14);
    final bodySmall = bodyLarge.copyWith(fontSize: 12);

    final displayLarge = TextStyle(
      fontFamily: GoogleFonts.quicksand().fontFamily,
      fontSize: 34,
      fontWeight: FontWeight.w300,
      color: onSurface,
    );
    final displayMedium = displayLarge.copyWith(fontSize: 28);
    final displaySmall = displayLarge.copyWith(fontSize: 22);

    final _textTheme = TextTheme(
      //Used in Textfields inside the body of pages
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,

      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,

      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
    );

    final _appBarTheme = AppBarThemeData(
      backgroundColor: surface,
      foregroundColor: onSurface,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
    );

    final _tabBarTheme = TabBarThemeData(
      labelStyle: bodyLarge,
      labelColor: secondary,
      indicatorColor: secondary,
      unselectedLabelColor: onSurface,
      unselectedLabelStyle: bodyLarge,
    );

    final _checkboxTheme = CheckboxThemeData(
      checkColor: WidgetStateProperty.all(onPrimary),
      fillColor: WidgetStateProperty.all(primary),
    );

    final _textButtonTheme = TextButtonThemeData(
        style: TextButton.styleFrom(
      foregroundColor: onSurface,
      textStyle: bodyLarge,
    ));

    final _elevatedButtonTheme = ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      textStyle: bodyLarge,
    ));

    final _inputDecorationTheme = InputDecorationTheme(
        filled: true,
        isDense: true,
        fillColor: surfaceContainer,
        prefixIconColor: onSurface,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: bodyMedium,
        labelStyle: bodyMedium,
        hintStyle: bodyMedium,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary, width: 2.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: surfaceContainer, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: error, width: 1.5),
        ));

    final _scrollbarTheme = ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true),
        interactive: true,
        thickness: WidgetStateProperty.all(10),
        radius: Radius.circular(10),
        thumbColor: WidgetStateProperty.all(primary.withValues(alpha: 0.5)));

    final _dividerTheme = DividerThemeData(
      color: onSurface.withValues(alpha: 0.30),
      thickness: 0.5,
      space: 1,
    );

    final _segmentedButtonTheme = SegmentedButtonThemeData(
        style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return onPrimary;
        }
        return onSurface;
      }),
      textStyle: WidgetStateProperty.all(bodyMedium),
      iconSize: WidgetStateProperty.all(16),
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(horizontal: 8),
      ),
    ));

    final _popupMenuTheme = PopupMenuThemeData(
      textStyle: bodyMedium,
      color: surfaceContainer,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: _colorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: _appBarTheme,
      tabBarTheme: _tabBarTheme,
      dropdownMenuTheme: DropdownMenuThemeData(textStyle: bodyMedium),
      cardTheme: CardThemeData(color: surfaceContainer),
      checkboxTheme: _checkboxTheme,
      textButtonTheme: _textButtonTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      scrollbarTheme: _scrollbarTheme,
      dividerTheme: _dividerTheme,
      segmentedButtonTheme: _segmentedButtonTheme,
      popupMenuTheme: _popupMenuTheme,
    );
  }
}
