import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/services/auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen>{

  String email = "";
  String password = "";

  Auth auth = new Auth();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Login",
              style: GoogleFonts.oswald(
                fontWeight: FontWeight.w300,
                fontSize: 50,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 300,
              height: 60,
              child: TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    hintText: 'email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 300,
              height: 60,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  hintText: 'password',
                ),
                keyboardType: TextInputType.text,
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: (){
                  auth.signInWithEmail(email, password);
                },
                child: Text(
                  "sign in"
                ),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(
                      "no account yet?",
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                    TextButton(
                      child: Text(
                        "sign up",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline
                        ),
                      ),
                      onPressed: (){
                        Navigator.pushNamed(context, '/registration');//TODO: Link zu RegistrationScreen einfügen.
                       },
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

