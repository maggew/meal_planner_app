import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/model/GroupInfo.dart';
import 'package:meal_planner/model/GroupPic.dart';
import 'package:meal_planner/screens/zoom_pic_screen.dart';
import 'package:meal_planner/services/auth.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:meal_planner/services/database.dart';

class ShowSingleGroupScreen extends StatefulWidget {
  static const route = '/show_singleGroup';

  @override
  State<ShowSingleGroupScreen> createState() => _ShowSingleGroupScreen();
}

class _ShowSingleGroupScreen extends State<ShowSingleGroupScreen> {
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

  String groupID = "";
  List groupMembers = [];
  List<Widget> allMembers = [];


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    GroupInfo groupInfo = ModalRoute.of(context).settings.arguments;
    Image grImage;

    groupMembers = groupInfo.groupMembers;
    int numberMembers;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    if(groupInfo.groupPic == "" || groupInfo.groupPic == 'assets/images/group_pic.jpg'){
      grImage = Image.asset(
        'assets/images/group_pic.jpg',
        fit: BoxFit.cover,);
    }
    else{
      grImage = Image.network(groupInfo.groupPic, fit: BoxFit.cover
      );
    }


    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Opacity(
            opacity: 0.55,
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: TextButton(
              child: Text(
                "< zurück",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            leadingWidth: 85,
          ),
          body: Center(
            child: Column(
              children: [
                Text(
                  groupInfo.groupName,
                  style: Theme.of(context).textTheme.headline2,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Column(
                        children: [
                          GestureDetector(
                            child: Container(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(30)),
                              ),
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              child: Hero(
                                tag: 'zoom',
                                child: grImage
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, ZoomPicScreen.route,
                                  arguments: GroupInfo(groupInfo.groupName, groupInfo.groupID, groupInfo.groupPic, groupInfo.groupMembers));
                            },
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Gruppen-ID",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          SizedBox(height: 10),
                          SelectableText(
                            groupInfo.groupID,
                            onTap: () {
                              Clipboard.setData(
                                      ClipboardData(text: groupInfo.groupID))
                                  .then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Gruppen-ID wurde in die Zwischenablage kopiert.",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                    duration: Duration(seconds: 3),
                                    margin:
                                        EdgeInsets.only(left: 20, right: 20),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Mitglieder",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          SizedBox(height: 10),
                          FutureBuilder(
                            future: Database().getAllMemberNames(groupMembers),
                            builder: (context, snapshot){

                              while(snapshot.connectionState == ConnectionState.waiting){
                                return Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.green,
                                    ));
                              }

                              if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              }

                              else {
                                if (snapshot.hasData) {
                                  numberMembers = snapshot.data.length;
                                } else {
                                  numberMembers = 0;
                                }

                                for (int i = 0; i < numberMembers; i++){
                                  allMembers.add(Text(snapshot.data[i]));
                                }
                              }
                              return Column(
                                children: allMembers,
                              );
                            },
                          ),
                          SizedBox(height: 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: 90,
                                width: 90,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green[100],
                                  ),
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          changeGroup(groupInfo.groupID)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        AppIcons.group_3,
                                        color: Colors.black,
                                        size: 35,
                                      ),
                                      SizedBox(height: 6),
                                      Column(
                                        children: [
                                          Text(
                                            "Gruppe\nauswählen",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11.5,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 90,
                                width: 90,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green[100],
                                  ),
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          leaveGroup(groupInfo.groupID)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 10, top: 6),
                                        child: Icon(
                                          AppIcons.logout,
                                          color: Colors.black,
                                          size: 32,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Column(
                                        children: [
                                          Text(
                                            "Gruppe\nverlassen",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11.5,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget leaveGroup(String groupID) {
    return AlertDialog(
      elevation: 10,
      backgroundColor: Colors.lightGreen[100],
      title: Text(
        "Möchtest du die Gruppe endgültig verlassen?",
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 25,
          fontFamily: GoogleFonts.aBeeZee().fontFamily,
          color: Colors.black,
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Nein",
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 20,
            ),
          ),
        ),
        MaterialButton(
          onPressed: () async {
            await Database().leaveGroup(groupID).then((value) {
              if(value == 'no_group'){
                Navigator.pushNamedAndRemoveUntil(context, '/groups', (route) => false);
              }
              else {
                Navigator.pushNamedAndRemoveUntil(context, '/show_userGroups', (route) => false);
              }
            });

          },
          child: Text(
            "Ja",
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget changeGroup(String groupID) {
    return AlertDialog(
      elevation: 10,
      backgroundColor: Colors.lightGreen[100],
      title: Text(
        "Möchtest du deine aktuelle Gruppe wechseln?",
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 25,
          fontFamily: GoogleFonts.aBeeZee().fontFamily,
          color: Colors.black,
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Nein",
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 20,
            ),
          ),
        ),
        MaterialButton(
          onPressed: () {
            Database().updateActiveGroup(groupID).then((value) {
              Navigator.pushNamedAndRemoveUntil(context, '/show_userGroups', (route) => false);
            });
          },
          child: Text(
            "Ja",
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
