import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/appstyle/app_theme.dart';
import 'package:meal_planner/presentation/router/router.dart';
import 'package:meal_planner/widgets/DismissKeyboard.dart';
// import 'package:meal_planner/presentation/cookbook/cookbook_page.dart';
// import 'package:meal_planner/presentation/create_group_screen.dart';
// import 'package:meal_planner/presentation/detailed_weekplan_screen.dart';
// import 'package:meal_planner/presentation/group_created_screen.dart';
// import 'package:meal_planner/presentation/join_group_screen.dart';
// import 'package:meal_planner/presentation/login/login_page.dart';
// import 'package:meal_planner/presentation/refrigerator_screen.dart';
// import 'package:meal_planner/presentation/registration_screen.dart';
// import 'package:meal_planner/presentation/show_recipe.dart';
// import 'package:meal_planner/presentation/show_singleGroup_screen.dart';
// import 'package:meal_planner/presentation/show_userGroups_screen.dart';
// import 'package:meal_planner/presentation/zoom_pic_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

//TODO: dart run build_runner build

class MyApp extends StatelessWidget {
  final String groupName;

  MyApp({Key? key, this.groupName = ''}) : super(key: key);
  final _appRouter = AppRouter();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: AppTheme().getAppTheme(),
        routerConfig: _appRouter.config(),
        // home: WelcomeScreen(), //Todo Welcome screen hier einsetzen
        // routes: {
        //   '/registration': (context) => RegistrationScreen(),
        //   '/login': (context) => LoginPage(),
        //   '/groups': (context) => GroupScreen(),
        //   '/create_group': (context) => CreateGroupScreen(),
        //   '/group_created': (context) => GroupCreatedScreen(
        //         groupName: groupName,
        //       ),
        //   '/join_group': (context) => JoinGroupScreen(),
        //   '/detailed_week': (context) => DetailedWeekScreen(),
        //   '/cookbook': (context) => CookbookPage(),
        //   RecipeScreen.route: (context) => RecipeScreen(),
        //   //'/add_recipe_keyboard': (context) => AddRecipeKeyboardScreen(),
        //   '/show_userGroups': (context) => ShowUserGroupsScreen(),
        //   ShowSingleGroupScreen.route: (context) => ShowSingleGroupScreen(),
        //   ZoomPicScreen.route: (context) => ZoomPicScreen(),
        //   RefrigeratorScreen.route: (context) => RefrigeratorScreen(),
        // },
      ),
    );
  }
}
