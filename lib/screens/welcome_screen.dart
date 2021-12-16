import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:meal_planner/screens/login_screen.dart';

class WelcomeScreen extends StatefulWidget{
  @override
  State<WelcomeScreen> createState() => _WelcomeScreen();
}

class _WelcomeScreen extends State<WelcomeScreen> {

  @override
  void initState() {
    super.initState();
    new Future.delayed(
        const Duration(seconds: 2),
            () => Navigator.of(context).push(_createRoute()),
        );
  }

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
          ),
        ],
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child,),
      transitionDuration: Duration(milliseconds: 900),
    );
  }

}

