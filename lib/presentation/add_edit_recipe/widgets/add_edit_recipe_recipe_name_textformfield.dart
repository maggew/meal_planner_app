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
      spacing: 10,
      children: [
        Text(
          "Rezeptname",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(
          width: 270,
          child: TextFormField(
            controller: recipeNameController,
            validator: _validateRecipeName,
            autovalidateMode: AutovalidateMode.disabled,
            decoration: InputDecoration(
              labelText: "Rezeptname",
              hintText: 'Rezeptname',
            ),
            keyboardType: TextInputType.text,
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
