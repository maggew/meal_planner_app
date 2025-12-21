import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/cookbook/cookbook_page.dart';
import 'package:meal_planner/presentation/login_screen.dart';
import 'package:meal_planner/services/auth.dart';
import 'package:meal_planner/services/database.dart';

import 'group_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreen();
}

class _AuthScreen extends State<AuthScreen> {
  String? currentGroup;

  @override
  void initState() {
    super.initState();
    Future.wait([
      Database().getCurrentGroupID().then((value) {
        currentGroup = value;
      })
    ]);
    print(currentGroup);
  }

  Auth auth = Auth();
  late String uid;

  @override
  Widget build(BuildContext context) {
    uid = auth.getCurrentUser();
    print(currentGroup);

    if (uid.isNotEmpty && uid != "") {
      return FutureBuilder(
          future: Database().getCurrentGroupID(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: Colors.green,
              ));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              if (snapshot.hasData) {
                if (snapshot.data == '' || snapshot.data == null) {
                  return GroupScreen();
                } else {
                  return CookbookScreen();
                }
              } else {
                return GroupScreen();
              }
            }
          });
    } else {
      return LoginScreen();
    }
  }
}
