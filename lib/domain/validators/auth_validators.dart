import 'package:email_validator/email_validator.dart';

class AuthValidators {
  static String? name(String? name) {
    if (name == null || name.isEmpty) {
      return "Bitte Name eingeben.";
    } else if (name.length < 3) {
      return "Der Name ist zu kurz.";
    } else {
      return null;
    }
  }

  static String? email(String? email) {
    if (email == null || email.isEmpty) {
      return "Bitte E-Mail Adresse eingeben.";
    } else if (!EmailValidator.validate(email)) {
      return "Bitte richtige E-Mail Adresse eingeben.";
    } else {
      return null;
    }
  }

  static String? registrationPassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Bitte Passwort eingeben.";
    } else if (password.length < 6) {
      return "Das Passwort ist zu kurz.";
    } else if (!password.contains(RegExp(r'[0-9]'))) {
      return "Passwort benötigt mind. eine Ziffer.";
    } else
      return null;
  }

  static String? passwordCheck(String? passwordCheck, String password) {
    if (passwordCheck == null || passwordCheck.isEmpty) {
      return "Bitte Passwort wiederholen.";
    } else if (password != passwordCheck) {
      return "Passwörter stimmen nicht überein.";
    } else {
      return null;
    }
  }

  static String? loginPassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Bitte Passwort eingeben.";
    }
    return null;
  }
}
