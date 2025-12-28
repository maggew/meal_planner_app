import 'package:flutter/material.dart';

class AddRecipeInstructions extends StatelessWidget {
  final TextEditingController recipeInstructionsController;
  const AddRecipeInstructions({
    super.key,
    required this.recipeInstructionsController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Anleitung",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey, width: 1.5),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          width: MediaQuery.of(context).size.width,
          height: 300,
          child: TextFormField(
            controller: recipeInstructionsController,
            decoration: InputDecoration(
              errorStyle: Theme.of(context).textTheme.bodyLarge,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              hintText: 'Hier ist Platz für die Kochanweisungen...',
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
        ),
      ],
    );
  }
}
