import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  ThemeData getAppTheme() {
    return ThemeData(
      scaffoldBackgroundColor: Colors.transparent,
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.all(Colors.green[400]),
      ),
      textTheme: TextTheme(
        //used to indicate big missing information
        titleLarge: TextStyle(
          fontFamily: GoogleFonts.oswald().fontFamily,
          fontSize: 40,
          color: Colors.red,
        ),
        // used for normal Headlines
        displayMedium: TextStyle(
          fontFamily: GoogleFonts.aBeeZee().fontFamily,
          fontSize: 30,
          color: Colors.black,
        ),
        //used for small headlines
        displaySmall: TextStyle(
          fontFamily: GoogleFonts.aBeeZee().fontFamily,
          fontSize: 25,
          fontWeight: FontWeight.w600,
          color: Colors.black,
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
          color: Colors.black,
        ),
        // used for error messages in Textformfields
        bodyLarge: TextStyle(
          fontFamily: GoogleFonts.quicksand().fontFamily,
          color: Colors.red[600],
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
          foregroundColor: Colors.black,
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
          backgroundColor: Colors.green[400],
          textStyle: TextStyle(
            fontFamily: GoogleFonts.quicksand(
              fontWeight: FontWeight.w500,
            ).fontFamily,
            fontSize: 17.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        prefixIconColor: Colors.black,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: TextStyle(
          color: Colors.black,
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
            color: Colors.green[800]!,
            width: 2.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.5),
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
