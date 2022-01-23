import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/model/RecipeInfo.dart';
import 'package:meal_planner/screens/show_recipe.dart';
import 'package:meal_planner/services/database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meal_planner/services/auth.dart';
import 'package:meal_planner/services/webData.dart';
import 'dart:ui';
import 'dart:math';
import 'dart:io';

import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';

class TextScan {

  File _pickedImageFile;

  TextScan(this._pickedImageFile);

  Future<String> getText() async {

    String _resultString;

    try {
      _resultString = await SimpleOcrPlugin.performOCR(_pickedImageFile.path);
      print("OCR results => $_resultString");

    } catch(e) {
      print("exception on OCR operation: ${e.toString()}");
    }
    return _resultString;
  }
}