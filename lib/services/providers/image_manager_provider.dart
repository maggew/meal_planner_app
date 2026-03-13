import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/core/constants/firebase_constants.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_manager_provider.g.dart';

enum AnalysisImageType { ingredients, instructions, photo }

class CustomImages {
  final File? ingredientsImage;
  final File? instructionsImage;
  final File? photo;
  final String? error;
  // Laufender/abgeschlossener Upload-Future für das Rezeptfoto
  final Future<String?>? pendingPhotoUpload;

  const CustomImages({
    this.ingredientsImage,
    this.instructionsImage,
    this.photo,
    this.error,
    this.pendingPhotoUpload,
  });

  CustomImages copyWith({
    File? Function()? ingredientsImage,
    File? Function()? instructionsImage,
    File? Function()? photo,
    String? Function()? error,
    Future<String?>? Function()? pendingPhotoUpload,
  }) {
    return CustomImages(
      ingredientsImage:
          ingredientsImage != null ? ingredientsImage() : this.ingredientsImage,
      instructionsImage: instructionsImage != null
          ? instructionsImage()
          : this.instructionsImage,
      photo: photo != null ? photo() : this.photo,
      error: error != null ? error() : this.error,
      pendingPhotoUpload: pendingPhotoUpload != null
          ? pendingPhotoUpload()
          : this.pendingPhotoUpload,
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
    // Vorherigen Fehler zurücksetzen
    state = state.copyWith(error: () => null);
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
      debugPrint('Error picking image from camera: $e');
      state = state.copyWith(
          error: () => 'Kamera konnte nicht geöffnet werden');
    }
  }

  Future<void> pickImageFromGallery(
      {required AnalysisImageType imageType}) async {
    // Vorherigen Fehler zurücksetzen
    state = state.copyWith(error: () => null);
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
      debugPrint('Error picking image from gallery: $e');
      state = state.copyWith(
          error: () => 'Bild konnte nicht geladen werden');
    }
  }

  void clearError() {
    state = state.copyWith(error: () => null);
  }

  void _setImage(File file, AnalysisImageType imageType) {
    switch (imageType) {
      case AnalysisImageType.ingredients:
        state = state.copyWith(ingredientsImage: () => file);
      case AnalysisImageType.instructions:
        state = state.copyWith(instructionsImage: () => file);
      case AnalysisImageType.photo:
        final uploadFuture = _startUpload(file);
        state = state.copyWith(
          photo: () => file,
          pendingPhotoUpload: () => uploadFuture,
        );
    }
  }

  void clearIngredientsImage() {
    state = state.copyWith(ingredientsImage: () => null);
  }

  void clearInstructionsImage() {
    state = state.copyWith(instructionsImage: () => null);
  }

  void clearPhoto() {
    state = state.copyWith(photo: () => null, pendingPhotoUpload: () => null);
  }

  void setPhoto(File file) {
    state = state.copyWith(
      photo: () => file,
      pendingPhotoUpload: () => _startUpload(file),
    );
  }

  void clearAll() {
    state = const CustomImages();
  }

  /// Löscht ein hochgeladenes Foto aus Firebase Storage, falls der Rezept-Upload
  /// abgebrochen wurde. Wird in dispose() der Formular-Seite aufgerufen.
  /// Nach erfolgreichem Speichern ist pendingPhotoUpload bereits null → No-op.
  Future<void> cleanupPendingPhoto() async {
    final pending = state.pendingPhotoUpload;
    if (pending == null) return;
    state = const CustomImages();
    final url = await pending;
    if (url != null) {
      await ref.read(storageRepositoryProvider).deleteImage(url);
    }
  }

  Future<String?> _startUpload(File file) async {
    try {
      return await ref
          .read(storageRepositoryProvider)
          .uploadImage(file, FirebaseConstants.imagePathRecipe);
    } catch (_) {
      return null;
    }
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
