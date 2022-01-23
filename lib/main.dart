import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/appstyle/app_theme.dart';
import 'package:meal_planner/screens/add_recipe_keyboard_screen.dart';
import 'package:meal_planner/screens/cookbook_screen.dart';
import 'package:meal_planner/screens/create_group_screen.dart';
import 'package:meal_planner/screens/detailed_weekplan_screen.dart';
import 'package:meal_planner/screens/group_created_screen.dart';
import 'package:meal_planner/screens/join_group_screen.dart';
import 'package:meal_planner/screens/refrigerator_screen.dart';
import 'package:meal_planner/screens/show_recipe.dart';
import 'package:meal_planner/screens/show_singleGroup_screen.dart';
import 'package:meal_planner/screens/show_userGroups_screen.dart';
import 'dart:async';
import 'package:meal_planner/screens/welcome_screen.dart';
import 'package:meal_planner/screens/login_screen.dart';
import 'package:meal_planner/screens/registration_screen.dart';
import 'package:meal_planner/screens/group_screen.dart';
import 'package:meal_planner/screens/zoom_pic_screen.dart';
import 'package:meal_planner/widgets/DismissKeyboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String groupName;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: AppTheme().getAppTheme(),
          home: WelcomeScreen(), //Todo Welcome screen hier einsetzen
          routes: {
            '/registration': (context) => RegistrationScreen(),
            '/login': (context) => LoginScreen(),
            '/groups': (context) => GroupScreen(),
            '/create_group': (context) => CreateGroupScreen(),
            '/group_created': (context) => GroupCreatedScreen(
                  groupName: groupName,
                ),
            '/join_group': (context) => JoinGroupScreen(),
            '/detailed_week': (context) => DetailedWeekScreen(),
            '/cookbook': (context) => CookbookScreen(),
            RecipeScreen.route: (context) => RecipeScreen(),
            '/add_recipe_keyboard': (context) => AddRecipeKeyboardScreen(),
            '/show_userGroups': (context) => ShowUserGroupsScreen(),
            ShowSingleGroupScreen.route: (context) => ShowSingleGroupScreen(),
            ZoomPicScreen.route: (context) => ZoomPicScreen(),
            RefrigeratorScreen.route: (context) => RefrigeratorScreen(),
          }),
    );
  }
}
