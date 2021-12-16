import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/services/auth.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  State<RegistrationScreen> createState() => _RegistrationScreen();
}

class _RegistrationScreen extends State<RegistrationScreen> {

  String name = "";
  String email = "";
  String password = "";
  String password_check = "";

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
              "Registration",
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
                  hintText: 'name',
                ),
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  setState(() {
                    name = value;
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
            SizedBox(
              width: 300,
              height: 60,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  hintText: 'repeat password',
                ),
                keyboardType: TextInputType.text,
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    password_check = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                auth.registerWithEmail(name, email, password, password_check);
              },
              child: Text("sign up"),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "already got an account?",
                  style: TextStyle(
                      color: Colors.black
                  ),
                ),
                TextButton(
                  child: Text(
                    "sign in",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline
                    ),
                  ),
                  onPressed: (){
                    Navigator.pushNamed(context, '/login');//TODO: Link zu RegistrationScreen einfügen.
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
