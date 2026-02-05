import 'package:flutter/material.dart';

class CreateGroupInputTextfield extends StatelessWidget {
  final TextEditingController groupNameController;
  const CreateGroupInputTextfield({
    super.key,
    required this.groupNameController,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: groupNameController,
      decoration: InputDecoration(
        errorStyle: Theme.of(context).textTheme.bodyLarge,
        labelText: "Gruppenname",
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blueGrey,
            width: 1.5,
          ),
        ),
        hintText: 'Gruppenname',
      ),
      keyboardType: TextInputType.text,
    );
  }
}
