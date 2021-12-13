import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Icon(
                Icons.fastfood,
                color: Colors.black,
                size: 150,
            ),
          ),
          Text(
            """Willkommen zum
            meal planner""",
            style: GoogleFonts.cuteFont(fontSize: 30),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}