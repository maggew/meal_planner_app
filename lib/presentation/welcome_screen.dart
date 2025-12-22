import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:meal_planner/presentation/authentification/auth_page.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<WelcomeScreen> createState() => _WelcomeScreen();
}

class _WelcomeScreen extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    new Future.delayed(
      const Duration(milliseconds: 1500),
      () => Navigator.of(context).pushReplacement(_createRoute()),
    );
  }

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Opacity(
            opacity: 0.7,
            child: RotatedBox(
              quarterTurns: 3,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Image(
                  image: AssetImage('assets/images/background.png'),
                ),
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image(
                  image: AssetImage('assets/images/caticorn.png'),
                  height: 100,
                ),
              ),
              SizedBox(height: 35),
              Center(
                child: FittedBox(
                  child: Text(
                    "Willkommen zum", //todo schrift ändern
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: GoogleFonts.aBeeZee().fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: FittedBox(
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
              ),
              SizedBox(height: 50),
              Image(
                image: AssetImage('assets/images/avocado_light.png'),
                height: 200,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AuthScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: animation,
        child: child,
      ),
      transitionDuration: Duration(milliseconds: 900),
    );
  }
}
