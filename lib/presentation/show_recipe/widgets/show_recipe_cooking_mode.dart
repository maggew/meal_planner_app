import 'package:flutter/material.dart';
import 'package:meal_planner/model/Recipe.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ShowRecipeCookingMode extends StatefulWidget {
  final Recipe recipe;
  const ShowRecipeCookingMode({super.key, required this.recipe});

  @override
  State<ShowRecipeCookingMode> createState() => _ShowRecipeCookingModeState();
}

class _ShowRecipeCookingModeState extends State<ShowRecipeCookingMode> {
  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
