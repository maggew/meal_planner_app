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
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(_usedWhite),
        fillColor: WidgetStateProperty.all(_usedGreen),
      ),
      textTheme: TextTheme(
        //used to indicate big missing information
        titleLarge: TextStyle(
          fontFamily: GoogleFonts.oswald().fontFamily,
          fontSize: 40,
          color: _usedRed,
        ),
        // used for normal Headlines
        displayMedium: TextStyle(
          fontFamily: GoogleFonts.aBeeZee().fontFamily,
          fontSize: 30,
          color: _usedBlack,
        ),
        //used for small headlines
        displaySmall: TextStyle(
          fontFamily: GoogleFonts.aBeeZee().fontFamily,
          fontSize: 25,
          fontWeight: FontWeight.w600,
          color: _usedBlack,
        ),
        // only used for WelcomeScreen
        bodySmall: TextStyle(
          fontFamily: GoogleFonts.quicksand(
            fontWeight: FontWeight.w500,
          ).fontFamily,
          fontSize: 12.5,
        ),
        // used for bigger headlines (login / registration)
        displayLarge: TextStyle(
          fontFamily: GoogleFonts.aBeeZee().fontFamily,
          fontSize: 50,
          color: _usedBlack,
        ),
        // used for error messages in Textformfields
        bodyLarge: TextStyle(
          fontFamily: GoogleFonts.quicksand().fontFamily,
          color: _usedDarkRed,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          fontFamily: GoogleFonts.quicksand(
            fontWeight: FontWeight.w400,
          ).fontFamily,
          fontSize: 15,
        ),
        // used for common texts
        bodyMedium: TextStyle(
          fontFamily: GoogleFonts.quicksand(
            fontWeight: FontWeight.w500,
          ).fontFamily,
          fontSize: 17.5,
        ),
      ),
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
      iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(backgroundColor: _usedLightGreen)),
      inputDecorationTheme: InputDecorationTheme(
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
