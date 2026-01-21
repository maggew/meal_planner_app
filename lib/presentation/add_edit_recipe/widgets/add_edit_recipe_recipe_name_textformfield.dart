import 'package:flutter/material.dart';

class AddEditRecipeRecipeNameTextformfield extends StatelessWidget {
  final TextEditingController recipeNameController;
  const AddEditRecipeRecipeNameTextformfield({
    super.key,
    required this.recipeNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rezeptname",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(height: 10),
        SizedBox(
          width: 270,
          height: 90,
          child: TextFormField(
            controller: recipeNameController,
            validator: _validateRecipeName,
            autovalidateMode: AutovalidateMode.disabled,
            decoration: InputDecoration(
              errorStyle: Theme.of(context).textTheme.bodyLarge,
              labelText: "Rezeptname",
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blueGrey,
                  width: 1.5,
                ),
              ),
              border: OutlineInputBorder(),
              hintText: 'Rezeptname',
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) {},
          ),
        )
      ],
    );
  }
}

String? _validateRecipeName(String? name) {
  if (name == null || name.isEmpty) {
    return "Bitte Rezeptname eingeben.";
  } else {
    return null;
  }
}
