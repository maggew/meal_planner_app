import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_add_recipe.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_body.dart';
import 'package:meal_planner/widgets/BurgerMenu_widget.dart';

class CookbookScreen extends StatelessWidget {
  const CookbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return AppBackground(
      scaffoldDrawer: BurgerMenu(width: 0.7),
      scaffoldAppBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          icon: Icon(Icons.menu), //FaIcon(FontAwesomeIcons.bars),
          onPressed: () {
            //scaffoldKey.currentState.openDrawer();
          },
        ),
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Kochbuch",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        centerTitle: true,
        actions: [
          Container(
            height: 40,
            width: 40,
            child: FloatingActionButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) => CookbookAddRecipe()),
              backgroundColor: Colors.lightGreen[100],
              child: Icon(
                AppIcons.plus_1,
                size: 35,
                color: Colors.black,
              ),
            ),
          ),
          //SizedBox(width: 15),
        ],
      ),
      scaffoldBody: CookbookBody(),
    );
  }
}
// class CookbookScreen extends StatefulWidget {
//   @override
//   State<CookbookScreen> createState() => _CookbookScreen();
// }
//
// class _CookbookScreen extends State<CookbookScreen> {
//   double getScreenWidth(BuildContext context) {
//     return MediaQuery.of(context).size.width;
//   }
//
//   double getScreenHeight(BuildContext context) {
//     return MediaQuery.of(context).size.height;
//   }
//
//   double getScreenHeightExcludeSafeArea(BuildContext context) {
//     final double height = MediaQuery.of(context).size.height;
//     final EdgeInsets padding = MediaQuery.of(context).padding;
//     return height - padding.top - padding.bottom;
//   }
//
//   double getHeightOfDropDownMenu(BuildContext context) {
//     final double height = MediaQuery.of(context).size.height;
//     final EdgeInsets padding = MediaQuery.of(context).padding;
//     return padding.top;
//   }
//
// /*  var groupName = "";
//
//   Future getGroupName() async {
//     groupName = await Database().getCurrentGroup();
//     if (groupName != null)  return groupName;
//     else return "";
//   }*/
//
//   /*Future recipes = Database().getSaucesRecipes();
//   var list;*/
//
//   File? imageFile;
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//     ]);
//
//     //getGroupName();
//     //print(recipes);
//
//     return CookbookBody();
//   }
//
//   Widget _buildRecipeList(int recipeCount, Widget widget) {
//     return ListView.builder(
//         itemCount: recipeCount,
//         itemExtent: 100,
//         itemBuilder: (context, index) {
//           return Container(
//             child: widget,
//             margin: EdgeInsets.only(top: 5, bottom: 5, left: 5),
//             color: Colors.white70,
//           );
//         });
//   }
//
//   Widget _showRecipe(BuildContext context, String recipeTitle, String imagePath,
//       List ingredients, int portions, String instructions) {
//     Image recipeImage;
//
//     if (imagePath == "" || imagePath == 'assets/images/default_pic_2.jpg') {
//       recipeImage = Image.asset(
//         'assets/images/default_pic_2.jpg',
//         fit: BoxFit.cover,
//       );
//     } else {
//       recipeImage = Image.network(imagePath, fit: BoxFit.cover);
//     }
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(context, RecipeScreen.route,
//             arguments: Recipe(
//                 title: recipeTitle,
//                 imagePath: imagePath,
//                 ingredients: ingredients,
//                 portions: portions,
//                 instructions: instructions));
//       },
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           SizedBox(width: 10),
//           Hero(
//             tag: recipeTitle,
//             child: Image(
//               width: 100,
//               height: 80,
//               fit: BoxFit.cover,
//               image: recipeImage.image,
//             ),
//           ),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               recipeTitle,
//               maxLines: 4,
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   FutureBuilder buildRecipeOverview(Future future) {
//     return FutureBuilder(
//         future: future,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//                 child: CircularProgressIndicator(
//               color: Colors.green,
//             ));
//           } else {
//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             } else {
//               int numberRecipes;
//               List<Widget> recipes = [];
//               var recipePic;
//               if (snapshot.hasData) {
//                 numberRecipes = snapshot.data.length;
//               } else {
//                 numberRecipes = 0;
//               }
//
//               for (int i = 0; i < numberRecipes; i++) {
//                 if (snapshot.data[i]["recipe_pic"] == "" ||
//                     snapshot.data[i]["recipe_pic"] == null) {
//                   recipePic = Image.asset(
//                     'assets/images/default_pic_2.jpg',
//                   );
//                 } else {
//                   recipePic = Image.network(
//                     snapshot.data[i]['recipe_pic'],
//                     fit: BoxFit.fill,
//                   );
//                 }
//                 recipes.add(new Container(
//                   height: 100,
//                   child: _showRecipe(
//                       context,
//                       snapshot.data[i]['name'],
//                       snapshot.data[i]['recipe_pic'],
//                       snapshot.data[i]['ingredients'],
//                       snapshot.data[i]['portions'],
//                       snapshot.data[i]['instruction']),
//                   margin: EdgeInsets.only(top: 5, bottom: 5, left: 5),
//                   color: Colors.white70,
//                 ));
//               }
//               return Container(
//                 color: Colors.lightGreen[100],
//                 margin: EdgeInsets.only(left: 10),
//                 padding: EdgeInsets.only(top: 5, left: 5),
//                 child: ListView(children: recipes),
//               );
//             }
//           }
//         });
//   }
//
  // List<Tab> getCategoryTabs() {
  //   return [
  //     Tab(
  //       child: Center(
  //         child: Column(
  //           children: [
  //             SizedBox(height: 8),
  //             Icon(
  //               AppIcons.soup,
  //               size: 30,
  //             ),
  //             Text("Suppen"),
  //             SizedBox(height: 8),
  //           ],
  //         ),
  //       ),
  //     ),
  //     Tab(
  //       child: Center(
  //         child: Column(
  //           children: [
  //             SizedBox(height: 8),
  //             Icon(
  //               AppIcons.salad,
  //               size: 30,
  //             ),
  //             Text("Salate"),
  //             SizedBox(height: 8),
  //           ],
  //         ),
  //       ),
  //     ),
  //     Tab(
  //       child: Center(
  //         child: Column(
  //           children: [
  //             SizedBox(height: 8),
  //             Icon(
  //               AppIcons.soup,
  //               size: 30,
  //             ),
  //             SizedBox(height: 5),
  //             Text(
  //               "Saucen,\nDips",
  //               textAlign: TextAlign.center,
  //               style: TextStyle(height: 0.9),
  //             ),
  //             SizedBox(height: 8),
  //           ],
  //         ),
  //       ),
  //     ),
  //     Tab(
  //       child: Center(
  //         child: Column(
  //           children: [
  //             SizedBox(height: 8),
  //             Icon(
  //               AppIcons.pizza,
  //               size: 30,
  //             ),
  //             SizedBox(height: 5),
  //             Text(
  //               "Haupt-\ngerichte",
  //               textAlign: TextAlign.center,
  //               style: TextStyle(height: 0.9),
  //             ),
  //             SizedBox(height: 8),
  //           ],
  //         ),
  //       ),
  //     ),
  //     Tab(
  //       child: Center(
  //         child: Column(
  //           children: [
  //             SizedBox(height: 8),
  //             Icon(
  //               AppIcons.ice_cream_cone,
  //               size: 30,
  //             ),
  //             Text("Desserts"),
  //             SizedBox(height: 8),
  //           ],
  //         ),
  //       ),
  //     ),
  //     Tab(
  //       child: Center(
  //         child: Column(
  //           children: [
  //             SizedBox(height: 8),
  //             Icon(
  //               AppIcons.wedding_cake,
  //               size: 30,
  //             ),
  //             Text("Gebäck"),
  //             SizedBox(height: 8),
  //           ],
  //         ),
  //       ),
  //     ),
  //     Tab(
  //       child: Center(
  //         child: Column(
  //           children: [
  //             SizedBox(height: 8),
  //             Icon(
  //               AppIcons.dish,
  //               size: 30,
  //             ),
  //             Text("Sonstiges"),
  //             SizedBox(height: 8),
  //           ],
  //         ),
  //       ),
  //     ),
  //     Tab(
  //       child: Center(
  //         child: Column(
  //           children: [
  //             SizedBox(height: 8),
  //             Image(
  //               image: AssetImage("assets/images/caticorn.png"),
  //               height: 40,
  //             ),
  //             SizedBox(height: 8),
  //           ],
  //         ),
  //       ),
  //     ),
  //   ];
  // }
//
// /* Widget tabsContent(String caption, [ String description = '' ] ) {
//     return Container(
//       margin: EdgeInsets.all(10),
//       padding: EdgeInsets.all(20),
//       color: Colors.black12,
//       child: Column(
//         children: <Widget>[
//           Text(
//             caption,
//             style: TextStyle(fontSize: 25),
//           ),
//           Divider(height: 20, color: Colors.black45,),
//           Text(
//             description,
//             style: TextStyle(fontSize: 15, color: Colors.black87),
//           ),
//         ],
//       ),
//     );
//   }*/
// }
