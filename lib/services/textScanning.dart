import 'dart:io';

//import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';

class TextScan {
  File _pickedImageFile;

  TextScan(this._pickedImageFile);

  Future<String> getText() async {
    String _resultString;

    try {
      //_resultString = await SimpleOcrPlugin.performOCR(_pickedImageFile.path);
      //print("OCR results => $_resultString");
    } catch (e) {
      print("exception on OCR operation: ${e.toString()}");
    }
    return _resultString = "ocr currently removed";
  }
}

