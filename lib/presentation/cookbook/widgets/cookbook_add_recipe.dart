import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/image_path_provider.dart';

class CookbookAddRecipe extends ConsumerWidget {
  const CookbookAddRecipe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    backgroundColor: Colors.lightGreen[300],
                  ),
                  onPressed: () {
                    ref.read(imagePathProvider.notifier).pickFromGallery();
                    //TextScan(imageFile).getText();
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
                    backgroundColor: Colors.lightGreen[300],
                  ),
                  onPressed: () {
                    ref.read(imagePathProvider.notifier).pickFromCamera();
                    //TextScan(imageFile);
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
                      backgroundColor: Colors.lightGreen[300],
                    ),
                    onPressed: () {
                      AutoRouter.of(context)
                          .push(const AddRecipeFromKeyboardRoute());
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
                      backgroundColor: Colors.lightGreen[300],
                    ),
                    onPressed: () async {
                      //var data = await WebData().fetchData("https://www.chefkoch.de/rezepte/884541194027076/Schlemmertopf-mit-Hackfleisch.html").then((value) => print(value));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // FaIcon(
                        //   FontAwesomeIcons.link,
                        // ),
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
}
