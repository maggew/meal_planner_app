import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_manager_provider.g.dart';

enum AnalysisImageType { ingredients, instructions, photo }

class CustomImages {
  final File? ingredientsImage;
  final File? instructionsImage;
  final File? recipePhoto;

  const CustomImages({
    this.ingredientsImage,
    this.instructionsImage,
    this.recipePhoto,
  });

  CustomImages copyWith({
    File? Function()? ingredientsImage,
    File? Function()? instructionsImage,
    File? Function()? recipePhoto,
  }) {
    return CustomImages(
      ingredientsImage:
          ingredientsImage != null ? ingredientsImage() : this.ingredientsImage,
      instructionsImage: instructionsImage != null
          ? instructionsImage()
          : this.instructionsImage,
      recipePhoto: recipePhoto != null ? recipePhoto() : this.recipePhoto,
    );
  }
}

@Riverpod(keepAlive: true)
class ImageManager extends _$ImageManager {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  CustomImages build() => const CustomImages();

  Future<void> pickImageFromCamera(
      {required AnalysisImageType imageType}) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (image != null) {
        File? file = File(image.path);
        file = await _cropImage(file);
        if (file != null) {
          _setImage(file, imageType);
        }
      }
    } catch (e) {
      print('Error picking image from camera: $e');
    }
  }

  Future<void> pickImageFromGallery(
      {required AnalysisImageType imageType}) async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false);
      if (result != null && result.files.single.path != null) {
        File? file = File(result.files.single.path!);
        file = await _cropImage(file);
        if (file != null) {
          _setImage(file, imageType);
        }
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
  }

  void _setImage(File file, AnalysisImageType imageType) {
    switch (imageType) {
      case AnalysisImageType.ingredients:
        state = state.copyWith(ingredientsImage: () => file);
      case AnalysisImageType.instructions:
        state = state.copyWith(instructionsImage: () => file);
      case AnalysisImageType.photo:
        state = state.copyWith(recipePhoto: () => file);
    }
  }

  void clearIngredientsImage() {
    state = state.copyWith(ingredientsImage: () => null);
  }

  void clearInstructionsImage() {
    state = state.copyWith(instructionsImage: () => null);
  }

  void clearRecipePhoto() {
    state = state.copyWith(recipePhoto: () => null);
  }

  void clearAll() {
    state = const CustomImages();
  }

  Future<File?> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Zuschneiden",
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: "Zuschneiden"),
      ],
    );
    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }
}

