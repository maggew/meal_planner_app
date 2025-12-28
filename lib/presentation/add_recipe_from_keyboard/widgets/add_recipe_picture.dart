import 'package:flutter/material.dart';
import 'package:meal_planner/appstyle/app_icons.dart';

class AddRecipePicture extends StatelessWidget {
  const AddRecipePicture({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                          textAlignVertical: TextAlignVertical.center,
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
                        icon: Icon(
                            Icons.camera_alt_outlined), //todo besseres Icon
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
      ],
    );
  }
}
