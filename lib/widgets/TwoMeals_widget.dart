import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'MealRowBreakfast_widget.dart';
import 'MealRowDinner_widget.dart';
import 'MealRowLunch_widget.dart';

class TwoMeals extends StatefulWidget {
  @override
  State<TwoMeals> createState() => _TwoMeals();
}

class _TwoMeals extends State<TwoMeals> {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Padding(
        padding: EdgeInsets.only(
          top: 5,
          left: 10,
          right: 10,
          bottom: 5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [       //todo wechselbare meals machen
            Expanded(
                flex: 1,
                child: MealRowLunch()
            ),
            Expanded(
                flex: 1,
                child: MealRowDinner()
            ),
          ],
        ),
      ),
    );
  }
}
