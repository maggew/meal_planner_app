import 'package:firebase_auth/firebase_auth.dart';
import 'package:meal_planner/services/database.dart';

class Auth {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future registerWithEmail(
      String name, String email, String password, String passwordCheck) async {
    if (password == passwordCheck) {
      try {
        // create new firebase user
        UserCredential user = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        // create a new document for the user with uid
        await Database().saveNewUser(name, user.user!.uid);

/*        // check if user already exists
        var isNewUser = user.additionalUserInfo.isNewUser;
        if(!isNewUser){
          // delete the created user
          user.user.delete();
        }*/
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
        //TODO: error handling
      }
    } else {
      print('Passwort stimmt nicht überein.');
      // TODO: error warning
    }
  }

  String getCurrentUser() {
    return _auth.currentUser?.uid ?? '';
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future signOut() async {
    _auth.signOut();
  }
}
