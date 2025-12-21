import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/presentation/refrigerator_screen.dart';
import 'package:meal_planner/services/auth.dart';
import 'package:meal_planner/services/database.dart';

class BurgerMenu extends StatefulWidget {
  const BurgerMenu({
    Key? key,
    required this.width,
  }) : super(key: key);

  final double width;

  @override
  State<BurgerMenu> createState() => _BurgerMenu();
}

class _BurgerMenu extends State<BurgerMenu> {
  double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double drawerWidth(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width * 0.5;
  }

  double getHeightOfDropDownMenu(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return padding.top;
  }

  Auth auth = Auth();
  String imagePath = "";
  var urlPath = "";
  var groupImage;

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Database().getCurrentGroup(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.green,
          ));
        } else {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            imagePath = snapshot.data['icon'];
            if (imagePath == "" || imagePath.isEmpty) {
              groupImage = Image.asset(
                'assets/images/group_pic.jpg',
                height: 200,
                width: widget.width * MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              );
            } else {
              groupImage = CachedNetworkImage(
                height: 200,
                width: widget.width * MediaQuery.of(context).size.width,
                imageUrl: imagePath,
                fit: BoxFit.cover,
              );
            }

            return SizedBox(
              width: widget.width * getScreenWidth(context),
              child: Drawer(
                backgroundColor: Colors.lightGreen[100],
                elevation: 20,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: getHeightOfDropDownMenu(context),
                      ),
                      Stack(
                        children: [
                          Container(
                            height: 200,
                            child: Align(
                              alignment: Alignment.center,
                              child: Opacity(
                                opacity: 0.8,
                                child: groupImage,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(Icons.keyboard_arrow_left)),
                          ),
                        ],
                      ),
                      SizedBox(
                        child: Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              snapshot.data['name'],
                              style: TextStyle(fontSize: 27.5),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        width: widget.width * getScreenWidth(context),
                        child: TextButton(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(AppIcons.calendar_1),
                              SizedBox(width: 10),
                              Text(
                                "Essensplan",
                              ),
                            ],
                          ),
                          onPressed: () {},
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 0,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: widget.width * getScreenWidth(context),
                        child: TextButton(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                AppIcons.recipe_book,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Kochbuch",
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/cookbook');
                          },
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 0,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: widget.width * getScreenWidth(context),
                        child: TextButton(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(AppIcons.shopping_list),
                              SizedBox(width: 10),
                              Text(
                                "Einkaufsliste",
                              ),
                            ],
                          ),
                          onPressed: () {},
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 0,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: widget.width * getScreenWidth(context),
                        child: TextButton(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(AppIcons.snowflake),
                              SizedBox(width: 10),
                              Text(
                                "Gefriertruhe",
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, RefrigeratorScreen.route);
                          },
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 0,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: widget.width * getScreenWidth(context),
                        child: TextButton(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(AppIcons.unity),
                              SizedBox(width: 10),
                              Text(
                                "Meine Gruppen",
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/show_userGroups');
                          },
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 0,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: widget.width * getScreenWidth(context),
                        child: TextButton(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(AppIcons.cat_1),
                              SizedBox(width: 10),
                              Text(
                                "Mein Profil",
                              ),
                            ],
                          ),
                          onPressed: () {},
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 0,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: widget.width * getScreenWidth(context),
                        child: TextButton(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(AppIcons.logout),
                              SizedBox(width: 10),
                              Text(
                                "Logout",
                              ),
                            ],
                          ),
                          onPressed: () async {
                            await auth.signOut();
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (r) => false);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } // snapshot.data  :- get your object which is pass from your downloadData() function
        }
      },
    );
  }
}
