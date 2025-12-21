import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/services/auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  String email = "";
  String password = "";

  Auth auth = new Auth();

  GlobalKey<FormState> _formCheck = new GlobalKey();

  //Screen is locked to portraitUp mode
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
                    Text(
                      "Login",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    SizedBox(
                      width: 300,
                      height: 100,
                      child: TextFormField(
                        //validator: _validateEmail,
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
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      height: 100,
                      child: TextFormField(
                        //validator: _validatePassword,
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
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(90, 40),
                      ),
                      onPressed: () async {
                        var message =
                            await auth.signInWithEmail(email, password);
                        if (_formCheck.currentState?.validate() == true &&
                            message == "success") {
                          Navigator.pushReplacementNamed(context, '/cookbook');
                        } else
                          SnackBar(
                            content: Text(message),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          );
                      },
                      child: Text(
                        "Login",
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    Text(
                      "Du hast noch keinen Account?",
                    ),
                    TextButton(
                      child: Text(
                        "Registrieren",
                        style: TextStyle(
                            color: Colors.green[100],
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/registration');
                      },
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
      return "Bitte Passwort eingeben.";
    } else
      return null;
  }
}
