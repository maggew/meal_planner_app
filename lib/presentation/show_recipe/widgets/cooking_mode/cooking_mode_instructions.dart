import 'package:flutter/material.dart';

class CookingModeInstructions extends StatelessWidget {
  final double pageMargin;
  final String instructionStep;
  final double borderRadius;
  const CookingModeInstructions({
    super.key,
    required this.pageMargin,
    required this.instructionStep,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: pageMargin),
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: 0.0,
            offset: Offset(5.0, 5.0),
          ),
        ],
      ),
      child: Text(instructionStep),
    );
  }
}
