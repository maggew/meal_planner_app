import 'dart:core';
import 'package:camera/camera.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:editable/editable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_number_picker/flutter_number_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/services/database.dart';
import 'dart:io';

class AddRecipeKeyboardScreen extends StatefulWidget {
  @override
  State<AddRecipeKeyboardScreen> createState() => _AddRecipeKeyboardScreen();
}

class _AddRecipeKeyboardScreen extends State<AddRecipeKeyboardScreen> {
  //row data
  List rows = [
    {'ingredient': ' ', 'number': ' ', 'unit': ' '},
  ];

  //Headers or Columns
  List headers = [
    {'title': 'Zutat', 'index': 1, 'key': 'ingredient'},
    {'title': 'Anzahl', 'index': 2, 'key': 'number'},
    {'title': 'Einheit', 'index': 3, 'key': 'unit'},
  ];

  // final _editableKey = GlobalKey<EditableState>();
  final _ingredientTable = GlobalKey<EditableState>();

  File imageFile = null;

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // dispose the controller
    super.dispose();
  }

  // This function is triggered when the user presses the back-to-top button
  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
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

  void _printTableData() {
    List editedRows = _ingredientTable.currentState.editedRows;
    List allRows = _ingredientTable.currentState.rows;
    //List<DataCell> _cells = [];

/*    _rowList.forEach((element) {
      _cells = element.cells.toList();
      _cells.forEach((element) {
        var widget = element.child;
        print(widget.toDiagnosticsNode().getProperties());
        //print(element.child);
      });
    });*/
  }

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

  List _categories = [
    {'label': 'Suppen', 'value': '1'},
    {'label': 'Salate', 'value': '2'},
    {'label': 'Saucen/Dips', 'value': '3'},
    {'label': 'Hauptgerichte', 'value': '4'},
    {'label': 'Desserts', 'value': '5'},
    {'label': 'Gebäck', 'value': '6'},
    {'label': 'Sonstiges', 'value': '7'},
  ];

  String recipeName = "";
  String category = "Suppen";

  int portions = 4;

  String instruction = "";
  String _iconPath = "";

  GlobalKey<FormState> _formCheck = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Opacity(
            opacity: 0.55,
            child: RotatedBox(
              quarterTurns: 3,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Image(
                  image: AssetImage('assets/images/background.png'),
                ),
              ),
            ),
          ),
        ),
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: TextButton(
              child: Text(
                "< zurück",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            leadingWidth: 85,
          ),
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Form(
                key: _formCheck,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rezeptname",
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 270,
                      height: 90,
                      child: TextFormField(
                        validator: _validateRecipeName,
                        autovalidateMode: AutovalidateMode.disabled,
                        decoration: InputDecoration(
                          errorStyle: Theme.of(context).textTheme.bodyText1,
                          labelText: "Rezeptname",
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                              width: 1.5,
                            ),
                          ),
                          border: OutlineInputBorder(),
                          hintText: 'Rezeptname',
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            recipeName = value;
                          });
                        },
                      ),
                    ),
                    Text(
                      "Kategorie",
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 10),
                    CoolDropdown(
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
                      resultTS:
                          Theme.of(context).inputDecorationTheme.hintStyle,
                      resultBD: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey, width: 1.5),
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      resultHeight: 60,
                      resultWidth: 270,
                      dropdownList: _categories,
                      defaultValue: _categories[0],
                      onChange: (v) {
                        setState(() {
                          var result = v.values.toList();
                          category = result[0];
                        });
                      },
                    ),
                    SizedBox(height: 30),
                    IntrinsicWidth(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Portionen",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueGrey),
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                            ),
                            child: CustomNumberPicker(
                              shape: Border.all(color: Colors.white),
                              valueTextStyle:
                                  Theme.of(context).textTheme.bodyText2,
                              initialValue: 4,
                              minValue: 1,
                              maxValue: 100,
                              step: 1,
                              onValue: (v) {
                                portions = v;
                              },
                            ),
                          ),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              Text(
                                "Zutaten",
                                style: Theme.of(context).textTheme.headline2,
                              ),
                              SizedBox(width: 3),
                              Tooltip(
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.only(left: 20, right: 20),
                                textStyle: TextStyle(
                                  fontSize: 15,
                                  fontFamily: GoogleFonts.aBeeZee().fontFamily,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.pink[100],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                preferBelow: false,
                                triggerMode: TooltipTriggerMode.tap,
                                message: Text(
                                  "Bitte verwende ausschließlich gängige "
                                  "Bezeichnungen für die Einheit deiner Zutaten:"
                                  "\n\ng, kg, l, ml, TL, EL, Stück, Prise, Msp, Bund",
                                  maxLines: 3,
                                ).data,
                                child: Padding(
                                    padding: EdgeInsets.only(top: 2.5),
                                    child: Icon(Icons.info_outline)),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.blueGrey, width: 1.5),
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                            ),
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            child: Editable(
                              createButtonAlign: CrossAxisAlignment.center,
                              thAlignment: TextAlign.center,
                              thSize: 20,
                              thPaddingBottom: 5,
                              thPaddingTop: 10,
                              columnRatio: 0.282,
                              stripeColor1: Colors.lightGreen[100],
                              stripeColor2: Colors.lightGreen[50],
                              zebraStripe: true,
                              key: _ingredientTable,
                              columns: headers,
                              rows: rows,
                              showCreateButton: true,
                              createButtonColor: Colors.lightGreen[100],
                              createButtonIcon: Icon(AppIcons.plus_1),
                              tdStyle: TextStyle(
                                fontSize: 15,
                                fontFamily: GoogleFonts.aBeeZee().fontFamily,
                              ),
                              showSaveIcon: false,
                              borderColor: Colors.transparent,
                              borderWidth: 2,
                              onSubmitted: (value) {
                                //new line
                              },
                              onRowSaved: (value) {
                                //added line
                              },
                            ),
                          ),
                          /*TextButton(
                              onPressed: () => _printTableData(),
                              child: Text('Show Data')),*/

                          // alternative table (without editing)
                          /* Column(
                            children: [
                              DataTable(
                                columns: [
                                  DataColumn(label: Text('Zutat')),
                                  DataColumn(label: Text('Anzahl')),
                                  DataColumn(label: Text('Einheit')),
                                ],
                                rows: _rowList,
                                key: _ingredientTable,

                              ),


                              FloatingActionButton.small(
                                onPressed: () {
                                  _addRow();
                                }, //
                                child: Text("+"),
                                backgroundColor: Colors.green,
                              ),
                            ],
                          ),*/
                          //TextButton(onPressed: () => {}, child: Text('Show Data')),
                          SizedBox(height: 30),
                          Text(
                            "Anleitung",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.blueGrey, width: 1.5),
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                            ),
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            child: TextFormField(
                              decoration: InputDecoration(
                                errorStyle:
                                    Theme.of(context).textTheme.bodyText1,
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                hintText:
                                    'Hier ist Platz für die Kochanweisungen...',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  instruction = value;
                                });
                              },
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            "Rezeptfoto",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          Text(
                            "(optional)",
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                          SizedBox(height: 15),
                          FittedBox(
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 270,
                                          height: 50,
                                          child: TextFormField(
                                            textAlign: TextAlign.start,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            onTap: () async {
                                              await _getFromGallery();
                                              setState(() {
                                              });
                                            },
                                            autovalidateMode:
                                                AutovalidateMode.always,
                                            readOnly: true,
                                            enabled: true,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white30,
                                              hintMaxLines: 2,
                                              hintText:
                                                  "\n" + _printPath(_iconPath),
                                              hintStyle: TextStyle(
                                                color: Colors.black,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.blueGrey,
                                                  width: 1.5,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.blueGrey,
                                                  width: 1.5,
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.blueGrey,
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        IconButton(
                                          onPressed: () {
                                            imageSelector(context);
                                          },
                                          icon: Icon(Icons
                                              .camera_alt_outlined), //todo besseres Icon
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      bottom: 3,
                                      left: 215,
                                      child: IconButton(
                                        onPressed: () async {
                                          await _getFromGallery();
                                          setState(() {
                                          });
                                        },
                                        icon: Icon(
                                          AppIcons.upload,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(130, 40),
                                ),
                                onPressed: () async {
                                  List ingredients = readData();
                                  //todo check if save was successful, else dont pop navigation

                                  if (_formCheck.currentState.validate() &&
                                      ingredients.isNotEmpty) {
                                    if (_iconPath != "" || _iconPath != null){
                                      await Database().uploadRecipeImageToFirebase(
                                          context, imageFile).then((url) {
                                        Database().saveNewRecipe(
                                            recipeName,
                                            translateCategory(category),
                                            portions,
                                            ingredients,
                                            instruction,
                                            url);
                                      });
                                    } else {
                                      Database().saveNewRecipe(
                                          recipeName,
                                          translateCategory(category),
                                          portions,
                                          ingredients,
                                          instruction,
                                          "");
                                    }

                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/cookbook', (r) => false);
                                  } else if (ingredients.isEmpty) {
                                    _scrollToTop();
                                    Fluttertoast.showToast(
                                      timeInSecForIosWeb: 5,
                                      msg: "Bitte Zutaten hinzufügen",
                                    );
                                    return null;
                                  } else {
                                    _scrollToTop();
                                    return null;
                                  }
                                },
                                child: Text(
                                  "Speichern",
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 100)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List readData() {
    //print(_ingredientTable.currentState.editedRows);
    List editedRows = _ingredientTable.currentState.editedRows;
    editedRows.forEach((element) {
      element.removeWhere((key, value) => key == 'row');
    });
    return editedRows;
  }

  String _validateRecipeName(String name) {
    if (name.isEmpty) {
      return "Bitte Rezeptname eingeben.";
    } else {
      return null;
    }
  }

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

  Future _getFromGallery() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      final path = result.files.single.path;
      setState(() {
        imageFile = File(path);
        _iconPath = path;
      });
    }
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

    if (imageFile != null) {
      _iconPath = imageFile.path;
      setState(() {
        debugPrint("SELECTED IMAGE PICK   $imageFile");
      });
    } else {
      print("You have not taken image");
    }
  }
}
