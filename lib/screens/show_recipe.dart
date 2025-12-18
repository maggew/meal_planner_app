import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorful_tab/flutter_colorful_tab.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/model/GroupInfo.dart';
import 'package:meal_planner/model/GroupPic.dart';
import 'package:meal_planner/model/RecipeInfo.dart';
import 'package:meal_planner/screens/show_singleGroup_screen.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:meal_planner/services/database.dart';

class RecipeScreen extends StatefulWidget {
  static const route = '/recipe';

  @override
  State<RecipeScreen> createState() => _RecipeScreen();
}

class _RecipeScreen extends State<RecipeScreen>
    with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List ingredients;

  @override
  Widget build(BuildContext context) {
    Recipe recipe = ModalRoute.of(context).settings.arguments;
    Image recipeImage;

    ingredients = recipe.ingredients;

    if (recipe.imagePath == "" ||
        recipe.imagePath == 'assets/images/default_pic_2.jpg') {
      recipeImage = Image.asset(
        'assets/images/default_pic_2.jpg',
        fit: BoxFit.cover,
      );
    } else {
      recipeImage = Image.network(recipe.imagePath, fit: BoxFit.fill);
    }

    Image image = recipeImage;
    final completer = Completer<ui.Image>();
    image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener(
            (ImageInfo info, bool syncCall) => completer.complete(info.image)));

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
          appBar: AppBar(
            backgroundColor: Colors.lightGreen[100],
            elevation: 0,
            leading: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            centerTitle: true,
            title: FittedBox(
                child: Text(
              recipe.title,
              style: Theme.of(context).textTheme.headline2,
            )),
            actions: [
              IconButton(
                onPressed: () {
                  //TODO: open editor for recipe
                },
                icon: Icon(
                  Icons.edit_outlined,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  //TODO: delete recipe from cookbook
                },
                icon: Icon(
                  AppIcons.trash_bin,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              SizedBox(width: 5),
            ],
          ),
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: false,
          body: FutureBuilder<ui.Image>(
            future: completer.future,
            builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
              if (snapshot.hasData) {
                return NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        flexibleSpace: Hero(
                          tag: recipe.title,
                          child: Image(
                            image: recipeImage.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        automaticallyImplyLeading: false,
                        stretch: true,
                        toolbarHeight: (MediaQuery.of(context).size.width /
                                (snapshot.data.width)) *
                            snapshot.data.height,
                      ),
                    ];
                  },
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.lightGreen[100],
                        child: ColorfulTabBar(
                          selectedHeight: 50,
                          unselectedHeight: 45,
                          indicatorHeight: 3,
                          topPadding: 3,
                          controller: controller,
                          labelColor: Colors.green,
                          tabs: [
                            TabItem(
                              color: Colors.green[200],
                              unselectedColor: Colors.lightGreen[200],
                              title: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      AppIcons.shopping_list,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Zutaten",
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            TabItem(
                              color: Colors.green[200],
                              unselectedColor: Colors.lightGreen[200],
                              title: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      AppIcons.dish,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Anleitung",
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: controller,
                          children: [
                            Container(
                              margin: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10.0,
                                    spreadRadius: 0.0,
                                    offset: Offset(5.0,
                                        5.0), // shadow direction: bottom right
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Portionen: " +
                                          recipe.portions.toString(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.black,
                                        color: Colors.transparent,
                                        shadows: [
                                          Shadow(
                                              color: Colors.black,
                                              offset: Offset(0, -5))
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    ScrollConfiguration(
                                      behavior: const ScrollBehavior()
                                          .copyWith(overscroll: false),
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: ingredients.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Column(
                                              children: [
                                                SizedBox(height: 5),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(ingredients[index]
                                                            ['number'] +
                                                        " "),
                                                    Text(ingredients[index]
                                                            ['unit'] +
                                                        " "),
                                                    Text(ingredients[index]
                                                        ['ingredient']),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                              ],
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10.0,
                                    spreadRadius: 0.0,
                                    offset: Offset(5.0,
                                        5.0), // shadow direction: bottom right
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.instructions.toString(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  /*SliverAppBar(
                  actions: [
                    IconButton(
                      onPressed: () {
                        //TODO: open editor for recipe
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        //TODO: delete recipe from cookbook
                      },
                      icon: Icon(
                        AppIcons.trash_bin,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 5),
                  ],
                  foregroundColor: Colors.black,
                  centerTitle: true,
                  title: FittedBox(
                      child: Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.headline2,
                  )),
                  backgroundColor: Colors.green[200],
                  flexibleSpace: Hero(
                    tag: recipe.title,
                    child: Image(
                      image: recipeImage.image,
                    ),
                  ),
                  floating: true,
                  expandedHeight: 250,
                  pinned: true,
                  primary: true,
                ),*/
                );
              } else {
                return const Text('Loading...');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _printIngredient() {
    Column allIngr = new Column();
    ingredients.forEach((element) {
      Row ingredientRow = new Row(
        children: [
          Text(element['number']),
          Text(element['unit'] + " "),
          Text(element['ingredient']),
        ],
      );
      allIngr.children.add(ingredientRow);
    });
    return allIngr;
  }
}

/*
Container(
margin: EdgeInsets.only(left: 20, right: 20, top: 20),
child: Column(
children: [
Container(
clipBehavior: Clip.antiAliasWithSaveLayer,
decoration: BoxDecoration(
borderRadius: BorderRadius.all(Radius.circular(100)),
),
width: MediaQuery.of(context).size.width,
child: Hero(
tag: recipe.title,
child: Image(
image: recipeImage.image,
),
),
),
SizedBox(height: 20),
Text(
recipe.title,
style: Theme.of(context).textTheme.headline2,
),
],
),
),*/
