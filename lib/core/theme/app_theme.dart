import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final Color _usedLightGreen = Colors.lightGreen[100]!;
final Color _usedGreen = Colors.green[400]!;
final Color _usedDarkGreen = Colors.green[800]!;

final Color _usedBlack = Colors.black;
final Color _usedWhite = Colors.white;

final Color _usedRed = Colors.red;
final Color _usedLightRed = Colors.red[300]!;
final Color _usedDarkRed = Colors.red[600]!;
final Color _usedViolet = Colors.deepPurple;

final Color _usedTransparent = Colors.transparent;
final Color _usedGrey = Colors.grey[100]!;
final Color _usedGrey800 = Colors.grey[800]!;
final Color _usedGrey700 = Colors.grey[700]!;
final Color _usedDarkGrey = Colors.grey[900]!;

class AppTheme {
  static ThemeData get light => _buildTheme(brightness: Brightness.light);
  static ThemeData get dark => _buildTheme(brightness: Brightness.dark);

  static ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    // Colors
    final backgroundColor = isDark ? _usedDarkGrey : _usedWhite;
    final textColor = isDark ? _usedWhite : _usedBlack;
    final cardColor = isDark ? _usedDarkGreen : _usedLightGreen;
    final greyFill = isDark ? _usedGrey800 : _usedLightGreen;

    // Text Styles
    final titleLarge = TextStyle(
      fontFamily: GoogleFonts.oswald().fontFamily,
      fontSize: 40,
      color: isDark ? _usedLightRed : _usedRed,
    );
    final titleMedium = titleLarge.copyWith(fontSize: 30);
    final titleSmall = titleLarge.copyWith(fontSize: 25);

    final bodyLarge = TextStyle(
      fontFamily: GoogleFonts.quicksand().fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: textColor,
    );
    final bodyMedium = bodyLarge.copyWith(fontSize: 16);
    final bodySmall = bodyLarge.copyWith(fontSize: 14);

    final displayLarge = TextStyle(
      fontFamily: GoogleFonts.aBeeZee().fontFamily,
      fontSize: 50,
      color: textColor,
    );
    final displayMedium = displayLarge.copyWith(fontSize: 40);
    final displaySmall = displayLarge.copyWith(fontSize: 30);

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

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: _usedTransparent,
      appBarTheme: AppBarThemeData(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: bodyLarge,
        labelColor: _usedViolet,
        indicatorColor: _usedViolet,
        unselectedLabelColor: textColor,
        unselectedLabelStyle: bodyLarge,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(textStyle: bodyMedium),
      cardTheme: CardThemeData(color: cardColor),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(_usedWhite),
        fillColor: WidgetStateProperty.all(_usedGreen),
      ),
      textTheme: _textTheme,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textColor,
          textStyle: TextStyle(
            fontFamily: GoogleFonts.quicksand(
              fontWeight: FontWeight.w500,
            ).fontFamily,
            fontSize: 17.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _usedGreen,
          textStyle: bodyLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: greyFill,
        isDense: true,
        prefixIconColor: textColor,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: bodyMedium,
        labelStyle: bodyMedium,
        hintStyle: bodyMedium,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _usedGrey800,
            width: 2.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? _usedGrey700 : _usedWhite,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _usedRed, width: 1.5),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true),
        interactive: true,
        thickness: WidgetStateProperty.all(10),
        radius: Radius.circular(10),
        thumbColor: WidgetStateProperty.all(Colors.teal[200]),
      ),
    );
  }
}
