import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/data/model/GroupInfo.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'dart:io';

import 'package:meal_planner/services/database.dart';

@RoutePage()
class ZoomPicturePage extends StatefulWidget {
  @override
  State<ZoomPicturePage> createState() => _ZoomPicturePage();
}

class _ZoomPicturePage extends State<ZoomPicturePage> {
  bool isLoading = false;
  File? _imageFile;
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    GroupInfo groupInfo =
        ModalRoute.of(context)?.settings.arguments as GroupInfo;
    Image grImage;

    if (groupInfo.groupPic == "" ||
        groupInfo.groupPic == 'assets/images/group_pic.jpg') {
      grImage = Image.asset(
        'assets/images/group_pic.jpg',
        fit: BoxFit.cover,
      );
    } else {
      grImage = Image.network(groupInfo.groupPic, fit: BoxFit.cover);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
            icon: Icon(Icons.keyboard_arrow_left),
            onPressed: () {
              AutoRouter.of(context).pop();
            }),
        actions: [
          IconButton(
            onPressed: () async {
              await _getFromGallery().then((v) async {
                setState(() {
                  isLoading = true;
                });
                if (_imagePath!.isNotEmpty || _imagePath != "") {
                  //TODO: rows below...
                  // await Database()
                  //     .deleteImageFromFirebase(groupInfo.groupPic)
                  //     .then((value) async {
                  //   await Database()
                  //       .uploadGroupImageToFirebase(context, _imageFile!)
                  //       .then((url) {
                  //     Database()
                  //         .updateGroupPic(groupInfo.groupID, url)
                  //         .then((value) {
                  //       setState(() {
                  //         isLoading = false;
                  //       });
                  //     });
                  //   });
                  // });
                }
                AutoRouter.of(context).push(const ShowUserGroupsRoute());
              });
            },
            icon: Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () async {
              // TODO: delete image in firestore first
              //TODO: rows below...
              // await Database()
              //     .deleteImageFromFirebase(groupInfo.groupPic)
              //     .then((value) async {
              //   await Database()
              //       .updateGroupPic(groupInfo.groupID, "")
              //       .then((value) {
              //     AutoRouter.of(context).push(const ShowUserGroupsRoute());
              //   });
              // });
            },
            icon: Icon(AppIcons.trash_bin),
          ),
          SizedBox(width: 10),
        ],
      ),
      extendBodyBehindAppBar: false,
      body: Hero(
        tag: 'zoom',
        child: Stack(
          children: [
            Center(
              child: grImage,
            ),
            Center(child: _buildAsyncInfo())
          ],
        ),
      ),
    );
  }

  Future _getFromGallery() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      final path = result.files.single.path;
      setState(() {
        _imageFile = File(path!);
        _imagePath = path;
      });
    }
  }

  Widget _buildAsyncInfo() {
    return isLoading
        ? CircularProgressIndicator(
            color: Colors.green,
          )
        : Text("");
  }
}
