import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/services/auth.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  State<RegistrationScreen> createState() => _RegistrationScreen();
}

class _RegistrationScreen extends State<RegistrationScreen> {
  String name = "";
  String email = "";
  String password = "";
  String passwordCheck = "";

  GlobalKey<FormState> _formCheck = new GlobalKey();

  Auth auth = new Auth();

  //Screen is locked to landscape mode
  @override
  void initState() {
    super.initState();
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
          body: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formCheck,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: Text(
                        "Registrierung",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    SizedBox(
                      width: 300,
                      height: 100,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Name",
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                              width: 1.5,
                            ),
                          ),
                          hintText: 'Name',
                          errorStyle: Theme.of(context).textTheme.bodyLarge,
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                        //validator: _validateName,
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      height: 100,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "E-Mail",
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                              width: 1.5,
                            ),
                          ),
                          hintText: 'E-Mail',
                          errorStyle: Theme.of(context).textTheme.bodyLarge,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        //validator: _validateEmail
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      height: 100,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Passwort",
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                              width: 1.5,
                            ),
                          ),
                          hintText: 'Passwort',
                          errorStyle: Theme.of(context).textTheme.bodyLarge,
                        ),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        //validator: _validatePassword,
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      height: 100,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Passwort wiederholen",
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                              width: 1.5,
                            ),
                          ),
                          hintText: 'Passwort wiederholen',
                          errorStyle: Theme.of(context).textTheme.bodyLarge,
                        ),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            passwordCheck = value;
                          });
                        },
                        //validator: _validatePasswordCheck,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(150, 40),
                      ),
                      onPressed: () {
                        if (_formCheck.currentState?.validate() == true) {
                          auth.registerWithEmail(
                              name, email, password, passwordCheck);
                          Navigator.pushReplacementNamed(context, '/groups');
                        }
                        ;
                      },
                      child: Text("Registrieren"),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Du hast schon einen Account?",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextButton(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.green[100],
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _validateName(String name) {
    if (name.isEmpty) {
      return "Bitte Name eingeben.";
    } else if (name.length < 3) {
      return "Der Name ist zu kurz.";
    } else {
      return null;
    }
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return "Bitte E-Mail Adresse eingeben.";
    } else if (!EmailValidator.validate(email)) {
      return "Bitte richtige E-Mail Adresse eingeben.";
    } else {
      return null;
    }
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return "Bitte Passwor t eingeben.";
    } else if (password.length < 6) {
      return "Das Passwort ist zu kurz.";
    } else if (!password.contains(RegExp(r'[0-9]'))) {
      return "Passwort benötigt mind. eine Ziffer.";
    } else
      return null;
  }

  String? _validatePasswordCheck(String passwordCheck) {
    if (passwordCheck.isEmpty) {
      return "Bitte Passwort wiederholen.";
    } else if (password != passwordCheck) {
      return "Passwörter stimmen nicht überein.";
    } else {
      return null;
    }
  }
}
