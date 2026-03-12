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
      decoration: const InputDecoration(
        labelText: 'Gruppenname',
        hintText: 'Gruppenname',
      ),
      keyboardType: TextInputType.text,
    );
  }
}
