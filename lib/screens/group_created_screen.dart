import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/services/auth.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

class GroupCreatedScreen extends StatefulWidget {
  final String groupName;

  GroupCreatedScreen({@required this.groupName});

  @override
  State<GroupCreatedScreen> createState() => _GroupCreatedScreen();
}

class _GroupCreatedScreen extends State<GroupCreatedScreen> {
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
  void initState(){
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[100],
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
      body: ListView(
        children: [
          LimitedBox(
            maxHeight: 600,
            maxWidth: getScreenWidth(context),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      "Du hast erfolgreich \ndie Gruppe",
                      style: Theme.of(context).textTheme.headline2,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      widget.groupName,
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "erstellt",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Gruppen-ID:"),
                    SizedBox(
                      width: 20,
                    ),
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: "_generatedGroupID"));
                      },
                      child: Text(
                        "generierte Gruppen-ID",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("Teilen in:"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.facebook),
                          iconSize: 50,
                          onPressed: () {
                            //Todo entsprechende verknüpfung erstellen
                          },
                        ),
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.whatsapp),
                          iconSize: 50,
                          onPressed: () {
                            //Todo entsprechende verknüpfung erstellen
                          },
                        ),
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.telegram),
                          iconSize: 50,
                          onPressed: () {
                            //Todo entsprechende verknüpfung erstellen
                          },
                        ),
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.instagram),
                          iconSize: 50,
                          onPressed: () {
                            //Todo entsprechende verknüpfung erstellen
                          },
                        ),
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.twitter),
                          iconSize: 50,
                          onPressed: () {
                            //Todo entsprechende verknüpfung erstellen
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(130, 40),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/detailed_week');
                    @override
                    dispose(){
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeRight,
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                      ]);
                      super.dispose();
                    }
                  },
                  child: Text(
                    "weiter",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _generatedGroupID(String name) {
    return "ss";
  }

  String _validateName(String name) {
    if (name.isEmpty) {
      return "Bitte Name eingeben.";
    } else if (name.length < 3) {
      return "Der Name ist zu kurz.";
    } else {
      return null;
    }
  }

  Future<String> _getFromGallery() async {
    XFile pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    String path;

    if (pickedFile != null) {
      String path = pickedFile.path;
      return path;
    } else
      return "";
  }
}
