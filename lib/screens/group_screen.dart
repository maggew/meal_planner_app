import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/services/auth.dart';
import 'dart:ui';

class GroupScreen extends StatefulWidget {
  @override
  State<GroupScreen> createState() => _GroupScreen();
}

class _GroupScreen extends State<GroupScreen> {
  double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double getScreenHeightExcludeSafeArea(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return height - padding.top - padding.bottom;
  }

  double getHeightOfDropDownMenu(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return padding.top;
  }

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
          body: SizedBox(
            height: getScreenHeight(context),
            width: getScreenWidth(context),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 140,
                  width: 140,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      onSurface: Colors.green[100],
                      primary: Colors.green[100],
                      elevation: 10,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/create_group');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 13),
                          child: Icon(
                            AppIcons.add,
                            color: Colors.black,
                          size: 80,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        FittedBox(
                          child: Text(
                            "Gruppe erstellen",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  height: 140,
                  width: 140,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      onSurface: Colors.green[100],
                      primary: Colors.green[100],
                      elevation: 10,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/join_group');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          AppIcons.cheers,
                          color: Colors.black,
                          size: 75,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        FittedBox(
                          child: Text(
                            "Gruppe beitreten",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 15,
          child: Image(       //todo tap caticorn shows heart and ups counter
            height: 50,
            image: AssetImage(
                'assets/images/caticorn.png',
            ),
          ),
        ),
      ],
    );
  }
}
