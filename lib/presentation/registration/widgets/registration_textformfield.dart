import 'package:flutter/material.dart';

class RegistrationTextformfield extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final String? Function(String?) validator;
  final FocusNode focusNode;
  final bool textObscured;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final VoidCallback onFieldSubmitted;
  final Widget? suffixIcon;
  const RegistrationTextformfield({
    super.key,
    required this.controller,
    required this.text,
    required this.validator,
    required this.focusNode,
    required this.textObscured,
    required this.textInputAction,
    required this.keyboardType,
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
          controller: controller,
          focusNode: focusNode,
          obscureText: textObscured,
          onFieldSubmitted: (_) => onFieldSubmitted(),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
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
        ),
      ),
    );
  }
}
