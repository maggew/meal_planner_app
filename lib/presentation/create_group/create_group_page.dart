import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/database.dart';
import 'package:meal_planner/services/auth.dart';
import 'dart:math';
import 'dart:io';

@RoutePage()
class CreateGroupPage extends StatefulWidget {
  @override
  State<CreateGroupPage> createState() => _CreateGroupPage();
}

class _CreateGroupPage extends State<CreateGroupPage> {
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

  String groupName = "";

  bool _breakfast = false;
  bool _lunch = false;
  bool _dinner = false;

  String _iconPath = "";
  File? _iconFile;

  Auth auth = Auth();

  GlobalKey<FormState> _formCheck = new GlobalKey();
  GlobalKey<FormState> _text = new GlobalKey();

  //Screen is locked to landscape mode
  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: AppBar(
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
            AutoRouter.of(context).pop();
          },
        ),
        leadingWidth: 85,
      ),
      scaffoldBody: Center(
        heightFactor: 1.15,
        child: SingleChildScrollView(
          child: Form(
            autovalidateMode: AutovalidateMode.disabled,
            key: _formCheck,
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Neue Kochgruppe",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 270,
                      height: 100,
                      child: TextFormField(
                        //validator: _validateName,
                        autovalidateMode: AutovalidateMode.disabled,
                        decoration: InputDecoration(
                          errorStyle: Theme.of(context).textTheme.bodyLarge,
                          labelText: "Gruppenname",
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                              width: 1.5,
                            ),
                          ),
                          hintText: 'Gruppenname',
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            groupName = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Plane Essen für:",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 270,
                          child: CheckboxListTile(
                            title: Text(
                              'Frühstück',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            visualDensity: VisualDensity.compact,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.only(left: 0),
                            dense: true,
                            value: _breakfast,
                            onChanged: (newValue) {
                              setState(() {
                                //_breakfast = newValue;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          width: 270,
                          child: CheckboxListTile(
                            title: Text(
                              'Mittagessen',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            visualDensity: VisualDensity.compact,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.only(left: 0),
                            value: _lunch,
                            onChanged: (newValue) {
                              setState(() {
                                //_lunch = newValue;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          width: 270,
                          child: CheckboxListTile(
                            title: Text(
                              'Abendessen',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            visualDensity: VisualDensity.compact,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.only(left: 0),
                            value: _dinner,
                            onChanged: (newValue) {
                              setState(() {
                                //_dinner = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      "Gruppen-Bild:",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Text(
                      "(optional)",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: 15),
                    FittedBox(
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                width: 270,
                                height: 50,
                                child: TextFormField(
                                  key: _text,
                                  textAlign: TextAlign.start,
                                  textAlignVertical: TextAlignVertical.center,
                                  onTap: () async {
                                    await _getFromGallery();
                                    setState(() {});
                                  },
                                  autovalidateMode: AutovalidateMode.always,
                                  readOnly: true,
                                  enabled: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white30,
                                    hintMaxLines: 2,
                                    hintText: "\n" + _printPath(_iconPath),
                                    hintStyle: TextStyle(
                                      color: Colors.black,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blueGrey,
                                        width: 1.5,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blueGrey,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 3,
                                right: 5,
                                child: IconButton(
                                  onPressed: () async {
                                    await _getFromGallery();
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    AppIcons.upload,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(120, 40),
                  ),
                  onPressed: () async {
                    if (_formCheck.currentState?.validate() == true) {
                      String userID = auth.getCurrentUser();
                      String groupID = createRandomGroupID();
                      if (_iconPath.isNotEmpty || _iconPath != "") {
                        await Database()
                            .uploadGroupImageToFirebase(context, _iconFile!)
                            .then((url) {
                          Database().createGroup(groupID, groupName, url);
                        });
                      } else {
                        Database().createGroup(groupID, groupName, "");
                      }
                      Database().updateGroupUsers(groupID, userID);
                      Database().updateUserGroups(groupID, userID);
                      Database().updateActiveGroup(groupID).then((value) {
                        AutoRouter.of(context).push(const CookbookRoute());
                      });
                    }
                  },
                  child: Text(
                    "erstellen",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  Future _getFromGallery() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      final path = result.files.single.path;
      setState(() {
        // _iconFile = File(path);
        // _iconPath = path;
      });
    }
  }

  String _printPath(String path) {
    if (path == "") {
      return "noch kein Bild ausgewählt";
    } else
      setState(() {});
    return "..." + _iconPath.substring(_iconPath.length - 22);
  }

  String createRandomGroupID() {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        10, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
}
