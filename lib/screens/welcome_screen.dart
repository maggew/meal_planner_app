import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:meal_planner/screens/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Icon(
                Icons.fastfood,
                color: Colors.black,
                size: 100,
            ),
          ),
          Center(
            child: Text(
              "Willkommen zum\nmeal planner",
              style: GoogleFonts.cuteFont(fontSize: 60),
              textAlign: TextAlign.center,
            ),
          ),
          Image(
            image: AssetImage('assets/images/avocado.png'),
            height: 200,
          )
        ],
      ),
    );
  }
}

