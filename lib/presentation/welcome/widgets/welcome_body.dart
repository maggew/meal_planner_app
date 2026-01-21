import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeBody extends StatelessWidget {
  const WelcomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage('assets/images/caticorn.png'),
            height: 100,
          ),
          SizedBox(height: 35),
          FittedBox(
            child: Text(
              "Willkommen zum", //TODO: schrift ändern
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: GoogleFonts.aBeeZee().fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          FittedBox(
            child: Text(
              "meal\nplanner",
              style: TextStyle(
                height: 0.9,
                color: Colors.black,
                fontSize: 70,
                fontFamily: GoogleFonts.aBeeZee().fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 50),
          Image(
            image: AssetImage('assets/images/avocado_light.png'),
            height: 200,
          ),
        ],
      ),
    );
  }
}
