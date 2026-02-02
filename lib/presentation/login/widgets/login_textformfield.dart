import 'package:flutter/material.dart';

class LoginTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String?> validator;
  final String text;
  final TextInputType textInputType;
  final bool textObscured;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final VoidCallback onFieldSubmitted;
  final Widget? suffixIcon;
  const LoginTextFormField({
    super.key,
    required this.controller,
    required this.validator,
    required this.text,
    required this.textInputType,
    required this.textObscured,
    required this.focusNode,
    required this.textInputAction,
    required this.onFieldSubmitted,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300),
        child: TextFormField(
          focusNode: focusNode,
          controller: controller,
          onFieldSubmitted: (_) => onFieldSubmitted(),
          textInputAction: textInputAction,
          validator: validator,
          obscureText: textObscured,
          decoration: InputDecoration(
            labelText: text,
            hintText: text,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueGrey, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorStyle: const TextStyle(
              fontSize: 12,
              height: 1.2,
              color: Colors.red,
            ),
            suffixIcon: suffixIcon,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ),
    );
  }
}
