import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/local_storage_service.dart';

@RoutePage()
class JoinGroupPage extends StatefulWidget {
  @override
  State<JoinGroupPage> createState() => _JoinGroupPage();
}

class _JoinGroupPage extends State<JoinGroupPage> {
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

  // double getHeightOfDropDownMenu(BuildContext context) {
  //   final double height = MediaQuery.of(context).size.height;
  //   final EdgeInsets padding = MediaQuery.of(context).padding;
  //   return padding.top;
  // }
  late final TextEditingController groupIdController;

  //Screen is locked to landscape mode
  @override
  void initState() {
    super.initState();
    groupIdController = TextEditingController();
  }

  @override
  void dispose() {
    groupIdController.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
                context.router.pop();
              },
            ),
            leadingWidth: 85,
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Gruppen-ID eingeben:",
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 100,
                  width: 270,
                  child: TextFormField(
                    controller: groupIdController,
                    autovalidateMode: AutovalidateMode.disabled,
                    //validator: _validateGroupID,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blueGrey,
                          width: 1.5,
                        ),
                      ),
                      hintText: "Gruppen-ID",
                      labelText: "Gruppen-ID",
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(150, 40),
                  ),
                  child: Text("beitreten"),
                  onPressed: () async {
                    print("groupId: ${groupIdController.text}");
                    if (groupIdController.text.isEmpty) return;

                    final storage = LocalStorageService();
                    await storage.saveActiveGroup(groupIdController.text);

                    print(
                        "gruppe lokal gespeichert: ${groupIdController.text}");
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // String _generatedGroupID(String name) {
  //   return "ss";
  // }
  //
  // String? _validateGroupID(String name) {
  //   if (name.isEmpty) {
  //     return "Bitte Name eingeben.";
  //   } else if (name.length < 3) {
  //     return "Der Name ist zu kurz.";
  //   } else {
  //     return null;
  //   }
  // }

  // Future<String> _getFromGallery() async {
  //   // XFile pickedFile =
  //   //     await ImagePicker().pickImage(source: ImageSource.gallery);
  //   // String path;
  //   //
  //   // String path = pickedFile.path;
  //   // return path;
  //   return "empty function";
  // }
}
