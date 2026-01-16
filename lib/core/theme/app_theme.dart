import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final Color _usedLightGreen = Colors.lightGreen[100]!;
final Color _usedGreen = Colors.green[400]!;
final Color _usedDarkGreen = Colors.green[800]!;

final Color _usedBlack = Colors.black;
final Color _usedWhite = Colors.white;

final Color _usedRed = Colors.red;
final Color _usedDarkRed = Colors.red[600]!;

final Color _usedTransparent = Colors.transparent;
final Color _usedGrey = Colors.grey[100]!;

class AppTheme {
  ThemeData getAppTheme() {
    return ThemeData(
      scaffoldBackgroundColor: _usedTransparent,
      // floatingActionButtonTheme: FloatingActionButtonThemeData(
      //     backgroundColor: _usedLightGreen, foregroundColor: _usedBlack),
      appBarTheme: AppBarThemeData(
        backgroundColor: _usedWhite,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(fontSize: 14),
      ),
      cardTheme: CardThemeData(color: _usedLightGreen),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(_usedWhite),
        fillColor: WidgetStateProperty.all(_usedGreen),
      ),
      textTheme: _textTheme,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _usedBlack,
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
          textStyle: TextStyle(
            fontFamily: GoogleFonts.quicksand(
              fontWeight: FontWeight.w500,
            ).fontFamily,
            fontSize: 17.5,
          ),
        ),
      ),
      // iconButtonTheme: IconButtonThemeData(
      //     style: IconButton.styleFrom(backgroundColor: _usedLightGreen)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _usedGrey,
        isDense: true,
        prefixIconColor: _usedBlack,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: TextStyle(
          color: _usedBlack,
        ),
        labelStyle: TextStyle(
          fontFamily: GoogleFonts.quicksand(
            fontWeight: FontWeight.w500,
          ).fontFamily,
        ),
        hintStyle: TextStyle(
          fontFamily: GoogleFonts.quicksand(
            fontWeight: FontWeight.w500,
          ).fontFamily,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _usedDarkGreen,
            width: 2.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _usedWhite,
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

final _textTheme = TextTheme(
  //Used in Textfields inside the body of pages
  bodyLarge: _bodyLarge,
  bodyMedium: _bodyMedium,
  bodySmall: _bodySmall,

  displayLarge: _displayLarge,
  displayMedium: _displayMedium,
  displaySmall: _displaySmall,

  titleLarge: _titleLarge,
  titleMedium: _titleMedium,
  titleSmall: _titleSmall,
);
final _titleLarge = TextStyle(
  fontFamily: GoogleFonts.oswald().fontFamily,
  fontSize: 40,
  color: _usedRed,
);
final _titleMedium = _titleLarge.copyWith(fontSize: 30);
final _titleSmall = _titleLarge.copyWith(fontSize: 25);

final _bodyLarge = TextStyle(
  fontFamily: GoogleFonts.quicksand().fontFamily,
  fontSize: 18,
  fontWeight: FontWeight.w500,
);
final _bodyMedium = _bodyLarge.copyWith(fontSize: 16);
final _bodySmall = _bodyLarge.copyWith(fontSize: 14);

final _displayLarge = TextStyle(
  fontFamily: GoogleFonts.aBeeZee().fontFamily,
  fontSize: 50,
  color: _usedBlack,
);
final _displayMedium = _displayLarge.copyWith(fontSize: 40);
final _displaySmall = _displayLarge.copyWith(fontSize: 30);
