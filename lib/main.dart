import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:meal_planner/screens/welcome_screen.dart';
import 'package:meal_planner/screens/login_screen.dart';
import 'package:meal_planner/screens/registration_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

//TODO: Fixate device orientation!

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              primary: Colors.green[700]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.green[400]
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.green[800],
                width: 2.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueGrey,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 1.5
            ),
          ),
        ),
      ),
      home: WelcomeScreen(),
      routes: {
        '/registration': (context) => RegistrationScreen(),
        '/login': (context) => LoginScreen(),
      }
    );
  }
}
