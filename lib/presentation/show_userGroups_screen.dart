import 'package:flutter/material.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/model/GroupInfo.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/services/database.dart';

class ShowUserGroupsScreen extends StatefulWidget {
  @override
  State<ShowUserGroupsScreen> createState() => _ShowUserGroupsScreen();
}

class _ShowUserGroupsScreen extends State<ShowUserGroupsScreen> {
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

  late Future groupData;

  //Screen is locked to landscape mode
  @override
  void initState() {
    super.initState();
    Database().getCurrentGroupID().then((id) {
      group_id = id;
    });
    groupData = Database().getAllGroupInfo();
  }

  String group_id = "";

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
            leading: IconButton(
              icon: Icon(
                Icons.home_outlined,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/cookbook');
              },
            ),
            leadingWidth: 65,
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/groups');
              },
              child: Icon(
                AppIcons.plus_1,
                color: Colors.black,
                size: 50,
              ),
              backgroundColor: Colors.lightGreen[100],
              elevation: 10),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: FutureBuilder(
              future: Future.wait([Database().getAllGroupInfo()]),
              builder: (context, snapshot) {
                while (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Colors.green,
                  ));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  int numberGroups;
                  List<Widget> groups = [];
                  var groupPic;
                  String transferGroupPic;
                  String groupID;
                  String groupName;
                  List groupMembers;

                  if (snapshot.hasData) {
                    numberGroups = snapshot.data?[0].length;
                  } else {
                    numberGroups = 0;
                  }
                  for (int i = 0; i < numberGroups; i++) {
                    if (snapshot.data?[0][i]["icon"] == "" ||
                        snapshot.data?[0][i]["icon"] == null) {
                      groupPic = Image.asset(
                        'assets/images/group_pic.jpg',
                      );
                      transferGroupPic = 'assets/images/group_pic.jpg';
                    } else {
                      groupPic = Image.network(
                        snapshot.data?[0][i]['icon'],
                        fit: BoxFit.fill,
                      );
                      transferGroupPic = snapshot.data?[0][i]['icon'];
                    }
                    groupID = snapshot.data?[0][i]['groupID'];
                    groupName = snapshot.data?[0][i]['name'];
                    groupMembers = snapshot.data?[0][i]['members'];

                    groups.add(new Container(
                      key: ValueKey(groupID),
                      padding: EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildGroupAvatar(groupName, transferGroupPic, groupID,
                              groupMembers),
                          Column(
                            children: [
                              SelectableText(
                                groupID,
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                                toolbarOptions: ToolbarOptions(copy: true),
                              ),
                              FittedBox(
                                child: Text(
                                  groupName,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ));
                  }
                  return Center(
                    child: Column(
                      children: [
                        Text(
                          "Meine Gruppen",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          mainAxisSpacing: 40,
                          crossAxisSpacing: 10,
                          padding: EdgeInsets.only(top: 50),
                          children: groups,
                        ),
                      ],
                    ),
                  );
                }
              }),
        ),
      ],
    );
  }

  Widget buildGroupAvatar(
      String grName, String image, String grID, List grMembers) {
    Image grImage;

    if (image == 'assets/images/group_pic.jpg' || image == "") {
      grImage = Image.asset(image);
    } else {
      grImage = Image.network(image);
    }

    if (group_id == grID) {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/show_singleGroup',
              arguments: GroupInfo(grName, grID, image, grMembers));
        },
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.pink[200]!,
              width: 3,
            ),
          ),
          child: CircleAvatar(
            backgroundImage: grImage.image,
            radius: 60,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/show_singleGroup',
              arguments: GroupInfo(grName, grID, image, grMembers));
        },
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            backgroundImage: grImage.image,
            radius: 60,
          ),
        ),
      );
    }
  }
}
