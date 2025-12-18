import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  ThemeData getAppTheme(){
    return ThemeData(
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(Colors.white),
        fillColor: MaterialStateProperty.all(Colors.green[400]),
      ),
      textTheme: TextTheme(
        //used to indicate big missing information
        headline6: TextStyle(
          fontFamily: GoogleFonts.oswald().fontFamily,
          fontSize: 40,
          color: Colors.red,
        ),
        // used for normal Headlines
        headline2: TextStyle(
          fontFamily: GoogleFonts.aBeeZee().fontFamily,
          fontSize: 30,
          color: Colors.black,
        ),
        //used for small headlines
        headline3: TextStyle(
          fontFamily: GoogleFonts.aBeeZee().fontFamily,
          fontSize: 25,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        // only used for WelcomeScreen
        caption: TextStyle(
          fontFamily: GoogleFonts.aBeeZee().fontFamily,
          fontSize: 70,
          color: Colors.black,
        ),
        // used for bigger headlines (login / registration)
        headline1: TextStyle(
          fontFamily: GoogleFonts.aBeeZee().fontFamily,
          fontSize: 50,
          color: Colors.black,
        ),
        // used for error messages in Textformfields
        bodyText1: TextStyle(
          fontFamily: GoogleFonts.quicksand().fontFamily,
          color: Colors.red[600],
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        subtitle2: TextStyle(
          fontFamily: GoogleFonts.quicksand(
            fontWeight: FontWeight.w400,
          ).fontFamily,
          fontSize: 15,
        ),
        // used for common texts
        bodyText2: TextStyle(
          fontFamily: GoogleFonts.quicksand(
            fontWeight: FontWeight.w500,
          ).fontFamily,
          fontSize: 17.5,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Colors.black,
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
          primary: Colors.green[400],
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
            color: Colors.green[800],
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
        isAlwaysShown: true,
        interactive: true,
        thickness: MaterialStateProperty.all(10),
        radius: Radius.circular(10),
        thumbColor: MaterialStateProperty.all(Colors.teal[200]),
      ),
    );
  }
}