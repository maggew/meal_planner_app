import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/services/providers/image_path_provider.dart';

class AddRecipePicture extends ConsumerStatefulWidget {
  const AddRecipePicture({Key? key}) : super(key: key);

  @override
  ConsumerState<AddRecipePicture> createState() => _AddRecipePictureState();
}

class _AddRecipePictureState extends ConsumerState<AddRecipePicture> {
  final TextEditingController _pictureNameController = TextEditingController();

  @override
  void dispose() {
    _pictureNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagePathAsync = ref.watch(imagePathProvider);
    imagePathAsync.whenData((path) {
      if (path != null) {
        _pictureNameController.text = path.split('/').last;
      } else {
        _pictureNameController.text = '';
      }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                          controller: _pictureNameController,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          onTap: () async {
                            ref
                                .read(imagePathProvider.notifier)
                                .pickFromGallery();
                          },
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
                          ref.read(imagePathProvider.notifier).pickFromCamera();
                        },
                        icon: Icon(
                            Icons.camera_alt_outlined), //todo besseres Icon
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 12.5,
                    left: 225,
                    child: Icon(
                      AppIcons.upload,
                      size: 25,
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
