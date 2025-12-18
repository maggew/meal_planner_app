import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/services/auth.dart';
import 'package:meal_planner/widgets/BurgerMenu_widget.dart';
import 'package:meal_planner/widgets/OneMeal_widget.dart';
import 'dart:ui';

import 'package:meal_planner/widgets/ThreeMeals_widget.dart';
import 'package:meal_planner/widgets/TwoMeals_widget.dart';

class DetailedWeekScreen extends StatefulWidget {
  @override
  State<DetailedWeekScreen> createState() => _DetailedWeekScreen();
}

class _DetailedWeekScreen extends State<DetailedWeekScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabBarController;

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
    _tabBarController = TabController(length: 7, vsync: this);
  }

  double drawerWidth(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width * 0.3;
  }

  double tabWidth(BuildContext context) {
    final double width = MediaQuery.of(context).size.height;
    return width / 7;
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.bars),
          onPressed: () {
            scaffoldKey.currentState.openDrawer();
          },
        ),
        foregroundColor: Colors.black,
        elevation: 0,
        backgroundColor: Colors.green[100],
        title: Row(
          children: [
            Text(
              "KW ",
            ),
            Text(
              "aktuelle Woche",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.exchangeAlt,
              color: Colors.red,
            ),
            onPressed: () {
              //todo ensprechende verknüpfung erstellen
            },
          ),
          SizedBox(
            width: 20,
          ),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.clipboardList),
            onPressed: () {
              Navigator.pushNamed(context, 'cookbook');
            },
          ),
          SizedBox(
            width: 20,
          ),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.cog),
            onPressed: () {
              //Todo entsprechende verknüpfung erstellen
            },
          ),
          SizedBox(
            width: 20,
          ),
        ],
        bottom: TabBar(
          controller: _tabBarController,
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.tab,
          enableFeedback: true,
          indicatorColor: Colors.purple,
          unselectedLabelColor: Colors.blueGrey,
          labelColor: Colors.purple,
          isScrollable: false,
          labelStyle: Theme.of(context).textTheme.bodyText2,
          labelPadding: EdgeInsets.all(0),
          physics: NeverScrollableScrollPhysics(),
          tabs: [
            Text("Montag"),
            Text("Dienstag"),
            Text("Mittwoch"),
            Text("Donnerstag"),
            Text("Freitag"),
            Text("Samstag"),
            Text("Sonntag"),
          ],
        ),
      ),
      drawer: BurgerMenu(width: 0.3),
      body: SafeArea(
        child: TabBarView(
          controller: _tabBarController,
          children: [
            ThreeMeals(),
            TwoMeals(),
            OneMeal(),
            ThreeMeals(),
            ThreeMeals(),
            ThreeMeals(),
            ThreeMeals(),
          ],
        ),
      ),
    );
  }
}
