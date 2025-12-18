import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_number_picker/flutter_number_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class MealRowLunch extends StatefulWidget {
  @override
  State<MealRowLunch> createState() => _MealRowLunch();
}

class _MealRowLunch extends State<MealRowLunch> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Stack(
            children: [
              Text(
                "Rezeptname",
                style: Theme.of(context).textTheme.headline6,
              ),
              Positioned(
                left: 20,
                child: Text(
                  "Mittagessen",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            LimitedBox(
              maxWidth: 200,
              child: Image(
                image: AssetImage('assets/images/team.png'),
              ),
            ),
            SizedBox(width:50),
            IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Personen"),
                  CustomNumberPicker(
                    valueTextStyle: Theme.of(context).textTheme.bodyText2,
                    shape: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                    initialValue: 4,
                    minValue: 1,
                    maxValue: 100,
                    step: 1,
                    onValue: (int ) {  },  //todo this returns the current value
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.bookOpen,
              ),
              onPressed: (){},      // todo set Path
            ),
            SizedBox(width: 20),
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.trashAlt,
              ),
              onPressed: (){},    // todo set Path
            ),
          ],
        ),
      ],
    );
  }
}