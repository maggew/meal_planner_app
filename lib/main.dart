import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/appstyle/app_theme.dart';
import 'package:meal_planner/presentation/cookbook/cookbook_page.dart';
import 'package:meal_planner/presentation/create_group_screen.dart';
import 'package:meal_planner/presentation/detailed_weekplan_screen.dart';
import 'package:meal_planner/presentation/group_created_screen.dart';
import 'package:meal_planner/presentation/group_screen.dart';
import 'package:meal_planner/presentation/join_group_screen.dart';
import 'package:meal_planner/presentation/login_screen.dart';
import 'package:meal_planner/presentation/refrigerator_screen.dart';
import 'package:meal_planner/presentation/registration_screen.dart';
import 'package:meal_planner/presentation/show_recipe.dart';
import 'package:meal_planner/presentation/show_singleGroup_screen.dart';
import 'package:meal_planner/presentation/show_userGroups_screen.dart';
import 'package:meal_planner/presentation/welcome_screen.dart';
import 'package:meal_planner/presentation/zoom_pic_screen.dart';
import 'package:meal_planner/widgets/DismissKeyboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String groupName;

  const MyApp({Key? key, this.groupName = ''}) : super(key: key);

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
            //'/add_recipe_keyboard': (context) => AddRecipeKeyboardScreen(),
            '/show_userGroups': (context) => ShowUserGroupsScreen(),
            ShowSingleGroupScreen.route: (context) => ShowSingleGroupScreen(),
            ZoomPicScreen.route: (context) => ZoomPicScreen(),
            RefrigeratorScreen.route: (context) => RefrigeratorScreen(),
          }),
    );
  }
}
