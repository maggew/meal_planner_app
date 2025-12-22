import 'package:flutter/material.dart';

class LoginTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String?> validator;
  final String text;
  final TextInputType textInputType;
  const LoginTextFormField(
      {super.key,
      required this.controller,
      required this.validator,
      required this.text,
      required this.textInputType});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 100,
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: text,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueGrey,
              width: 1.5,
            ),
          ),
          hintText: text,
          errorStyle: Theme.of(context).textTheme.bodyLarge,
        ),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }
}
