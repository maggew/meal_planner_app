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
            _addRecipeButton(
              text: "Datei",
              icon: Icon(AppIcons.file),
              callback: () {
                ref.read(imagePathProvider.notifier).pickFromGallery();
              },
            ),
            _addRecipeButton(
              text: "Foto",
              //TODO: search better camera icon
              icon: Icon(Icons.camera_alt_outlined),
              callback: () {
                ref.read(imagePathProvider.notifier).pickFromCamera();
              },
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _addRecipeButton(
              text: "Eingabe",
              icon: Icon(Icons.keyboard_alt_outlined),
              callback: () {
                AutoRouter.of(context).push(const AddRecipeFromKeyboardRoute());
              },
            ),
            _addRecipeButton(
              text: "URL",
              icon: Icon(Icons.satellite),
              //TODO: search better link icon
              callback: () async {
                print("muss noch implementiert werden");
                //TODO: must be implemented
              },
            ),
          ],
        ),
        //SizedBox(height: 15)
      ],
    );
  }

  Widget _addRecipeButton({
    required String text,
    required Icon icon,
    required void Function() callback,
  }) {
    return ElevatedButton(
        onPressed: callback,
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: Colors.lightGreen[300],
        ),
        child: SizedBox(
          height: 60,
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              Text(text),
            ],
          ),
        ));
  }
}
