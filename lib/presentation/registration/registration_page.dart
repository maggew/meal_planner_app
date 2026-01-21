import 'package:auto_route/auto_route.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/exceptions/auth_exceptions.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

@RoutePage()
class RegistrationPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  String name = "";
  String email = "";
  String password = "";
  String passwordCheck = "";
  bool _isLoading = false;

  GlobalKey<FormState> _formCheck = new GlobalKey();

  //Screen is locked to landscape mode
  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
                        validator: (value) => _validateName(value ?? ""),
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
                        validator: (value) => _validateEmail(value ?? ""),
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
                        validator: (value) => _validatePassword(value ?? ""),
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
                        validator: (value) =>
                            _validatePasswordCheck(value ?? ""),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(150, 40),
                      ),
                      onPressed: () {
                        _isLoading ? null : _register;
                      },
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text("Registrieren"),
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
                            context.router.push(const LoginRoute());
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

  Future<void> _register() async {
    if (_formCheck.currentState?.validate() != true) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);

      final uid = await authRepo.registerWithEmail(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );

      print('✅ Registrierung erfolgreich: $uid');

      if (mounted) {
        context.router.push(const GroupsRoute());
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Registrierung fehlgeschlagen: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
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
