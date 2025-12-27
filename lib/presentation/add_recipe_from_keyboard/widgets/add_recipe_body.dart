import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:editable/editable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/presentation/common/categories.dart';

class AddRecipeBody extends StatelessWidget {
  final ScrollController scrollController;
  final Key formCheck;
  const AddRecipeBody({
    super.key,
    required this.scrollController,
    required this.formCheck,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Form(
          key: formCheck,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rezeptname",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 270,
                height: 90,
                child: TextFormField(
                  validator: _validateRecipeName,
                  autovalidateMode: AutovalidateMode.disabled,
                  decoration: InputDecoration(
                    errorStyle: Theme.of(context).textTheme.bodyLarge,
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
                  onChanged: (value) {},
                ),
              ),
              Text(
                "Kategorie",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              SizedBox(height: 10),
              CoolDropdown(
                dropdownList: categoryDropdownItems(),
                onChange: (v) {},
                controller: DropdownController(),
              ),
              SizedBox(height: 30),
              IntrinsicWidth(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Portionen",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey),
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      child: Container(),
                      // child: CustomNumberPicker(
                      //   shape: Border.all(color: Colors.white),
                      //   valueTextStyle:
                      //       Theme.of(context).textTheme.bodyMedium,
                      //   initialValue: 4,
                      //   minValue: 1,
                      //   maxValue: 100,
                      //   step: 1,
                      //   onValue: (v) {
                      //     portions = v;
                      //   },
                      // ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text(
                          "Zutaten",
                          style: Theme.of(context).textTheme.displayMedium,
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
                            borderRadius: BorderRadius.all(Radius.circular(10)),
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
                        border: Border.all(color: Colors.blueGrey, width: 1.5),
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
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
                        stripeColor1: Colors.lightGreen[100]!,
                        stripeColor2: Colors.lightGreen[50]!,
                        zebraStripe: true,
                        // key: _ingredientTable,
                        // columns: headers,
                        // rows: rows,
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
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey, width: 1.5),
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      child: TextFormField(
                        decoration: InputDecoration(
                          errorStyle: Theme.of(context).textTheme.bodyLarge,
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
                          hintText: 'Hier ist Platz für die Kochanweisungen...',
                        ),
                        onChanged: (value) {},
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Rezeptfoto",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Text(
                      "(optional)",
                      style: Theme.of(context).textTheme.titleSmall,
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
                                        //TODO: hier den provider aufrufen
                                      },
                                      autovalidateMode: AutovalidateMode.always,
                                      readOnly: true,
                                      enabled: true,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white30,
                                        hintMaxLines: 2,
                                        //hintText: "\n" + _printPath(_iconPath),
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
                                      //imageSelector(context);
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
                                    //TODO: hier provider aufrufen?
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
                            //List ingredients = readData();
                            //todo check if save was successful, else dont pop navigation

                            // if (_formCheck.currentState.validate() &&
                            //     ingredients.isNotEmpty) {
                            //   if (_iconPath != "" || _iconPath != null) {
                            //     await Database()
                            //         .uploadRecipeImageToFirebase(
                            //             context, imageFile)
                            //         .then((url) {
                            //       Database().saveNewRecipe(
                            //           recipeName,
                            //           translateCategory(category),
                            //           portions,
                            //           ingredients,
                            //           instruction,
                            //           url);
                            //     });
                            //   } else {
                            //     Database().saveNewRecipe(
                            //         recipeName,
                            //         translateCategory(category),
                            //         portions,
                            //         ingredients,
                            //         instruction,
                            //         "");
                            //   }
                            //
                            //   Navigator.pushNamedAndRemoveUntil(
                            //       context, '/cookbook', (r) => false);
                            // } else if (ingredients.isEmpty) {
                            //   _scrollToTop();
                            //   Fluttertoast.showToast(
                            //     timeInSecForIosWeb: 5,
                            //     msg: "Bitte Zutaten hinzufügen",
                            //   );
                            //   return null;
                            // } else {
                            //   _scrollToTop();
                            //   return null;
                            // }
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
    );
  }
}

List<CoolDropdownItem<dynamic>> categoryDropdownItems() {
  List<CoolDropdownItem<dynamic>> out = [];
  for (int i = 0; i < categoryNames.length; i++) {
    out.add(CoolDropdownItem(label: categoryNames[i], value: i));
  }
  return out;
}

String? _validateRecipeName(String? name) {
  if (name == null || name.isEmpty) {
    return "Bitte Rezeptname eingeben.";
  } else {
    return null;
  }
}
