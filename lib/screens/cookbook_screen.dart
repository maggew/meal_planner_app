import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/model/RecipeInfo.dart';
import 'package:meal_planner/screens/show_recipe.dart';
import 'package:meal_planner/services/database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meal_planner/services/auth.dart';
import 'package:meal_planner/services/textScanning.dart';
import 'package:meal_planner/services/webData.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:math';

import 'package:meal_planner/widgets/BurgerMenu_widget.dart';
import 'package:vertical_tabs/vertical_tabs.dart';

class CookbookScreen extends StatefulWidget {
  @override
  State<CookbookScreen> createState() => _CookbookScreen();
}

class _CookbookScreen extends State<CookbookScreen> {
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

/*  var groupName = "";

  Future getGroupName() async {
    groupName = await Database().getCurrentGroup();
    if (groupName != null)  return groupName;
    else return "";
  }*/

  /*Future recipes = Database().getSaucesRecipes();
  var list;*/

  var scaffoldKey = GlobalKey<ScaffoldState>();

  File imageFile;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    //getGroupName();
    //print(recipes);

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
          key: scaffoldKey,
          backgroundColor: Colors.transparent,
          drawer: BurgerMenu(width: 0.7),
          appBar: AppBar(
            toolbarHeight: 80,
            leading: IconButton(
              icon: FaIcon(FontAwesomeIcons.bars),
              onPressed: () {
                scaffoldKey.currentState.openDrawer();
              },
            ),
            foregroundColor: Colors.black,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              "Kochbuch",
              style: Theme.of(context).textTheme.headline2,
            ),
            centerTitle: true,
            actions: [
              Container(
                height: 40,
                width: 40,
                child: FloatingActionButton(
                  onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => addRecipe()),
                  backgroundColor: Colors.lightGreen[100],
                  child: Icon(
                    AppIcons.plus_1,
                    size: 35,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 15),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 10),
              _SearchBar(),
              SizedBox(height: 20),
              Flexible(
                fit: FlexFit.tight,
                child: VerticalTabs(
                  tabsElevation: 50,
                  selectedTabBackgroundColor: Colors.lightGreen[100],
                  indicatorColor: Colors.pink[100],
                  backgroundColor: Colors.transparent,
                  tabsWidth: 100,
                  tabs: getCategoryTabs(),
                  contents: [
                    buildRecipeOverview(
                        Database().getRecipesFromCategory('soups')),
                    buildRecipeOverview(
                        Database().getRecipesFromCategory('salads')),
                    buildRecipeOverview(
                        Database().getRecipesFromCategory('sauces_dips')),
                    buildRecipeOverview(
                        Database().getRecipesFromCategory('mainDishes')),
                    buildRecipeOverview(
                        Database().getRecipesFromCategory('desserts')),
                    buildRecipeOverview(
                        Database().getRecipesFromCategory('bakery')),
                    buildRecipeOverview(
                        Database().getRecipesFromCategory('others')),
                    Container(
                      child: Center(
                        child: Text("Hier kommt noch was"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeList(int recipeCount, Widget widget) {
    return ListView.builder(
        itemCount: recipeCount,
        itemExtent: 100,
        itemBuilder: (context, index) {
          return Container(
            child: widget,
            margin: EdgeInsets.only(top: 5, bottom: 5, left: 5),
            color: Colors.white70,
          );
        });
  }

  Widget _showRecipe(
      BuildContext context, String recipeTitle, String imagePath, List ingredients, int portions, String instructions) {
    Image recipeImage;

    if (imagePath == "" ||
        imagePath == 'assets/images/default_pic_2.jpg') {
      recipeImage = Image.asset(
        'assets/images/default_pic_2.jpg',
        fit: BoxFit.cover,
      );
    } else {
      recipeImage = Image.network(imagePath, fit: BoxFit.cover);
    }

    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, RecipeScreen.route,
            arguments: Recipe(title: recipeTitle, imagePath: imagePath, ingredients: ingredients, portions: portions, instructions: instructions));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 10),
          Hero(
            tag: recipeTitle,
            child: Image(
              width: 100,
              height: 80,
              fit: BoxFit.cover,
              image: recipeImage.image,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              recipeTitle,
              maxLines: 4,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
    );
  }

  Widget addRecipe() {
    return AlertDialog(
      elevation: 10,
      backgroundColor: Colors.lightGreen[100],
      title: Text(
        "Wie möchtest du ein neues Rezept hinzufügen?",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          fontFamily: GoogleFonts.aBeeZee().fontFamily,
          color: Colors.black,
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 100,
              height: 60,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    primary: Colors.lightGreen[300],
                  ),
                  onPressed: () {
                    _getFromGallery();
                    TextScan(imageFile).getText()  ;
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(AppIcons.file),
                      Text("Datei"),
                    ],
                  )),
            ),
            SizedBox(
              width: 100,
              height: 60,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    primary: Colors.lightGreen[300],
                  ),
                  onPressed: () {

                    imageSelector(context);
                    TextScan(imageFile);

                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined),
                      //TODO: search better camera icon
                      Text("Foto"),
                    ],
                  )),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
                width: 100,
                height: 60,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      primary: Colors.lightGreen[300],
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/add_recipe_keyboard');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.keyboard_alt_outlined),
                        //TODO: search better keyboard icon
                        Text("Eingabe"),
                      ],
                    ))),
            SizedBox(
                height: 60,
                width: 100,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      primary: Colors.lightGreen[300],
                    ),
                    onPressed: () async {

                      //var data = await WebData().fetchData("https://www.chefkoch.de/rezepte/884541194027076/Schlemmertopf-mit-Hackfleisch.html").then((value) => print(value));

                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.link,
                        ),
                        //TODO: search better link icon
                        Text("URL"),
                      ],
                    ))),
          ],
        ),
        SizedBox(height: 15)
      ],
    );
  }

  FutureBuilder buildRecipeOverview(Future future) {
    return FutureBuilder(
        future: future,
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
              int numberRecipes;
              List<Widget> recipes = [];
              var recipePic;
              if (snapshot.hasData) {
                numberRecipes = snapshot.data.length;
              } else {
                numberRecipes = 0;
              }

              for (int i = 0; i < numberRecipes; i++) {
                if (snapshot.data[i]["recipe_pic"] == "" ||
                    snapshot.data[i]["recipe_pic"] == null) {
                  recipePic = Image.asset(
                    'assets/images/default_pic_2.jpg',
                  );
                } else {
                  recipePic = Image.network(
                    snapshot.data[i]['recipe_pic'],
                    fit: BoxFit.fill,
                  );
                }
                recipes.add(new Container(
                  height: 100,
                  child: _showRecipe(
                      context, snapshot.data[i]['name'], snapshot.data[i]['recipe_pic'], snapshot.data[i]['ingredients'], snapshot.data[i]['portions'], snapshot.data[i]['instruction']),
                  margin: EdgeInsets.only(top: 5, bottom: 5, left: 5),
                  color: Colors.white70,
                ));
              }
              return Container(
                color: Colors.lightGreen[100],
                margin: EdgeInsets.only(left: 10),
                padding: EdgeInsets.only(top: 5, left: 5),
                child: ListView(children: recipes),
              );
            }
          }
        });
  }

  List<Tab> getCategoryTabs() {
    return [
      Tab(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 8),
              Icon(
                AppIcons.soup,
                size: 30,
              ),
              Text("Suppen"),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      Tab(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 8),
              Icon(
                AppIcons.salad,
                size: 30,
              ),
              Text("Salate"),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      Tab(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 8),
              Icon(
                AppIcons.soup,
                size: 30,
              ),
              SizedBox(height: 5),
              Text(
                "Saucen,\nDips",
                textAlign: TextAlign.center,
                style: TextStyle(height: 0.9),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      Tab(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 8),
              Icon(
                AppIcons.pizza,
                size: 30,
              ),
              SizedBox(height: 5),
              Text(
                "Haupt-\ngerichte",
                textAlign: TextAlign.center,
                style: TextStyle(height: 0.9),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      Tab(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 8),
              Icon(
                AppIcons.ice_cream_cone,
                size: 30,
              ),
              Text("Desserts"),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      Tab(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 8),
              Icon(
                AppIcons.wedding_cake,
                size: 30,
              ),
              Text("Gebäck"),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      Tab(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 8),
              Icon(
                AppIcons.dish,
                size: 30,
              ),
              Text("Sonstiges"),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      Tab(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 8),
              Image(
                image: AssetImage("assets/images/caticorn.png"),
                height: 40,
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ];
  }

/* Widget tabsContent(String caption, [ String description = '' ] ) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      color: Colors.black12,
      child: Column(
        children: <Widget>[
          Text(
            caption,
            style: TextStyle(fontSize: 25),
          ),
          Divider(height: 20, color: Colors.black45,),
          Text(
            description,
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }*/

  Future imageSelector(BuildContext context) async {
    // CAMERA CAPTURE CODE
    imageFile = (await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 90)) as File;

    if (imageFile != null) {
      //_iconPath = imageFile.path;
      setState(() {
        debugPrint("SELECTED IMAGE PICK   $imageFile");
      });
    } else {
      print("You have not taken image");
    }
  }

  Future _getFromGallery() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      final path = result.files.single.path;
      setState(() {
        imageFile = File(path);
        //_iconPath = path;
      });
    }
  }


}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      height: 40,
      child: Stack(
        children: [
          TextFormField(
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.bottom,
            autovalidateMode: AutovalidateMode.always,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              hintText: "Suche",
              fillColor: Colors.white70,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}