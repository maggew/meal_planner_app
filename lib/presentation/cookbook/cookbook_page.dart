import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/burger_menu.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_add_recipe.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_body.dart';

@RoutePage()
class CookbookPage extends StatelessWidget {
  const CookbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldDrawer: BurgerMenu(width: 0.7),
      scaffoldAppBar: AppBar(
        toolbarHeight: 80,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu), //FaIcon(FontAwesomeIcons.bars),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
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
// }
