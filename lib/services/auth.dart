import 'package:firebase_auth/firebase_auth.dart';

class Auth {

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future registerWithEmail(String name, String email, String password,
      String passwordCheck) async {
    if (password == passwordCheck) {
      try {
        UserCredential user = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
      }
      on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      }
      catch (e) {
        print(e);
        //TODO: error handling
      }
    }
    else {
      print('Passwort stimmt nicht überein.');
      // TODO: error warning
    }
  }

  Future signInWithEmail(String email, String password) async {
    try {
      UserCredential user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    print("schein geklappt zu haben");
  }
}
