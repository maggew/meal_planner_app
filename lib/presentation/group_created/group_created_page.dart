import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

@RoutePage()
class GroupCreatedPage extends StatefulWidget {
  final String groupName;

  GroupCreatedPage({required this.groupName});

  @override
  State<GroupCreatedPage> createState() => _GroupCreatedPage();
}

class _GroupCreatedPage extends State<GroupCreatedPage> {
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
            context.router.pop();
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
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      widget.groupName,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "erstellt",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium,
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
                        style: Theme.of(context).textTheme.bodyLarge,
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
                          icon: Icon(Icons
                              .wallet), //FaIcon(FontAwesomeIcons.facebook),
                          iconSize: 50,
                          onPressed: () {
                            //Todo entsprechende verknüpfung erstellen
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons
                              .wallet), //FaIcon(FontAwesomeIcons.whatsapp),
                          iconSize: 50,
                          onPressed: () {
                            //Todo entsprechende verknüpfung erstellen
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons
                              .wallet), //FaIcon(FontAwesomeIcons.telegram),
                          iconSize: 50,
                          onPressed: () {
                            //Todo entsprechende verknüpfung erstellen
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons
                              .wallet), //FaIcon(FontAwesomeIcons.instagram),
                          iconSize: 50,
                          onPressed: () {
                            //Todo entsprechende verknüpfung erstellen
                          },
                        ),
                        IconButton(
                          icon: Icon(
                              Icons.wallet), //FaIcon(FontAwesomeIcons.twitter),
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
                    context.router.push(const DetailedWeekplanRoute());
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

  String? _validateName(String name) {
    if (name.isEmpty) {
      return "Bitte Name eingeben.";
    } else if (name.length < 3) {
      return "Der Name ist zu kurz.";
    } else {
      return null;
    }
  }

  Future<String> _getFromGallery() async {
    // XFile pickedFile =
    //     await ImagePicker().pickImage(source: ImageSource.gallery);
    // String path;
    //
    // String path = pickedFile.path;
    // return path;
    return "getFromGalleryString";
  }
}
