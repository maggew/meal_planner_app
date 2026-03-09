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
  final TextInputType keyboardType;
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
    required this.keyboardType,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffixIcon,
          ),
          keyboardType: keyboardType,
        ),
      ),
    );
  }
}
