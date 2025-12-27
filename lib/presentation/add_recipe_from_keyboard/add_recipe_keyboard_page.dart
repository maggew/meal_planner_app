import 'dart:core';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:editable/editable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_appbar.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_body.dart';
import 'package:meal_planner/presentation/common/app_background.dart';

// row data
List rows = [
  {'ingredient': ' ', 'number': ' ', 'unit': ' '},
];

//Headers or Columns
List headers = [
  {'title': 'Zutat', 'index': 1, 'key': 'ingredient'},
  {'title': 'Anzahl', 'index': 2, 'key': 'number'},
  {'title': 'Einheit', 'index': 3, 'key': 'unit'},
];

@RoutePage()
class AddRecipeFromKeyboardPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddRecipeFromKeyboardPage> createState() =>
      _AddRecipeFromKeyboardPage();
}

class _AddRecipeFromKeyboardPage
    extends ConsumerState<AddRecipeFromKeyboardPage> {
  // final _editableKey = GlobalKey<EditableState>();
  final _ingredientTable = GlobalKey<EditableState>();

  File? imageFile = null;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // OHNE Listener!
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

/*  List _units = [
    {'label': 'g', 'value': '1'},
    {'label': 'kg', 'value': '2'},
    {'label': 'Stk', 'value': '3'},
    {'label': 'ml', 'value': '4'},
    {'label': 'l', 'value': '5'},
    {'label': 'TL', 'value': '6'},
    {'label': 'EL', 'value': '7'},
    {'label': 'Prise', 'value': '8'},
    {'label': 'Msp', 'value': '9'},
    {'label': 'Bund', 'value': '10'},
  ];*/

//   void _printTableData() {
//     List editedRows = _ingredientTable.currentState?.editedRows;
//     List allRows = _ingredientTable.currentState.rows;
//     //List<DataCell> _cells = [];
//
// /*    _rowList.forEach((element) {
//       _cells = element.cells.toList();
//       _cells.forEach((element) {
//         var widget = element.child;
//         print(widget.toDiagnosticsNode().getProperties());
//         //print(element.child);
//       });
//     });*/
//   }

/*  List<DataRow> _rowList = [
    DataRow(cells: <DataCell>[
      DataCell(Text('AAAAAA')),
      DataCell(
        TextFormField(
          initialValue: 'g',
          keyboardType: TextInputType.text,
          onFieldSubmitted: (val) {
          },
        ),
      ),
      DataCell(
          Container(
            padding: EdgeInsets.all(20.0),
            child: DropdownButton(
                value: 1,
                items: [
              DropdownMenuItem(
                child: Text("First"),
                value: 1,
              ),
              DropdownMenuItem(
                child: Text("Second"),
                value: 2,
              ),
              DropdownMenuItem(
                  child: Text("Third"),
                  value: 3
              ),
              DropdownMenuItem(
                  child: Text("Fourth"),
                  value: 4
              )
            ], onChanged: (v){
            }),
          ),*/

  /*CoolDropdown(
          gap: 0,
          isAnimation: false,
          isTriangle: false,
          dropdownWidth: 247,
          dropdownBD: BoxDecoration(
            border: Border.all(color: Colors.blueGrey, width: 1.5),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          dropdownItemTopGap: 10,
          selectedItemTS: TextStyle(
            color: Colors.green,
            fontFamily: GoogleFonts.quicksand(
              fontWeight: FontWeight.w500,
            ).fontFamily,
            fontSize: 15,
          ),
          unselectedItemTS: TextStyle(
            color: Colors.black,
            fontFamily: GoogleFonts.quicksand(
              fontWeight: FontWeight.w500,
            ).fontFamily,
            fontSize: 15,
          ),
          resultTS: TextStyle(
            color: Colors.black,
            fontFamily: GoogleFonts.quicksand(
              fontWeight: FontWeight.w500,
            ).fontFamily,
            fontSize: 15,
          ),
          resultBD: BoxDecoration(
            border: Border.all(color: Colors.blueGrey, width: 1.5),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          resultHeight: 60,
          resultWidth: 270,
          dropdownList: [
            {'label': 'g', 'value': '1'},
            {'label': 'kg', 'value': '2'},
            {'label': 'Stk', 'value': '3'},
            {'label': 'ml', 'value': '4'},
            {'label': 'l', 'value': '5'},
            {'label': 'TL', 'value': '6'},
            {'label': 'EL', 'value': '7'},
            {'label': 'Prise', 'value': '8'},
            {'label': 'Msp', 'value': '9'},
            {'label': 'Bund', 'value': '10'},
          ],
          defaultValue: [
            {'label': 'g', 'value': '1'},
            {'label': 'kg', 'value': '2'},
            {'label': 'Stk', 'value': '3'},
            {'label': 'ml', 'value': '4'},
            {'label': 'l', 'value': '5'},
            {'label': 'TL', 'value': '6'},
            {'label': 'EL', 'value': '7'},
            {'label': 'Prise', 'value': '8'},
            {'label': 'Msp', 'value': '9'},
            {'label': 'Bund', 'value': '10'},
          ][0],
          onChange: (v) {
            var result = v.values.toList();
            print(result[0]);
          },
        ),*/ /*
      ),
    ]),
  ];*/

/*  void _addRow() {
    // Built in Flutter Method.
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below.
      _rowList.add(DataRow(cells: <DataCell>[
        DataCell(Text('BBBBBB')),
        DataCell(Text('2')),
        DataCell(Text('No')),
      ]));
    });
  }*/

  String recipeName = "";
  String category = "Suppen";

  int portions = 4;

  String instruction = "";
  String _iconPath = "";

  GlobalKey<FormState> _formCheck = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: AddRecipeAppbar(),
      scaffoldBody: AddRecipeBody(
        scrollController: _scrollController,
        formCheck: _formCheck,
      ),
    );
  }

  // List readData() {
  //   //print(_ingredientTable.currentState.editedRows);
  //   List editedRows = _ingredientTable.currentState.editedRows;
  //   editedRows.forEach((element) {
  //     element.removeWhere((key, value) => key == 'row');
  //   });
  //   return editedRows;
  // }

  String translateCategory(String category_ger) {
    if (category_ger == "Suppen")
      return "soups";
    else if (category_ger == "Salate")
      return "salads";
    else if (category_ger == "Saucen/Dips")
      return "sauces_dips";
    else if (category_ger == "Hauptgerichte")
      return "mainDishes";
    else if (category_ger == "Desserts")
      return "desserts";
    else if (category_ger == "Gebäck")
      return "bakery";
    else if (category_ger == "Sonstiges")
      return "others";
    else
      return "error";
  }


  String _printPath(String path) {
    // Todo ??????
    if (path == "") {
      return "noch kein Bild ausgewählt";
    } else
      setState(() {});
    return "..." + _iconPath.substring(_iconPath.length - 22);
  }

  Future imageSelector(BuildContext context) async {
    // CAMERA CAPTURE CODE
    imageFile = (await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 90)) as File;

    //_iconPath = imageFile.path;
    setState(() {
      debugPrint("SELECTED IMAGE PICK   $imageFile");
    });
  }
}
