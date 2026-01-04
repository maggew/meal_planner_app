import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_manager_provider.g.dart';

class CustomImages {
  final File? analysisImage;
  final File? recipePhoto;

  const CustomImages({
    this.analysisImage,
    this.recipePhoto,
  });

  CustomImages copyWith({
    File? Function()? analysisImage,
    File? Function()? recipePhoto,
  }) {
    return CustomImages(
      analysisImage:
          analysisImage != null ? analysisImage() : this.analysisImage,
      recipePhoto: recipePhoto != null ? recipePhoto() : this.recipePhoto,
    );
  }
}

@Riverpod(keepAlive: true)
class ImageManager extends _$ImageManager {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  CustomImages build() => const CustomImages();

  Future<void> pickImageFromCamera({required bool isAnalysisImage}) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image != null) {
        final file = File(image.path);
        if (isAnalysisImage) {
          state = state.copyWith(analysisImage: () => file);
        } else {
          state = state.copyWith(recipePhoto: () => file);
        }
      }
    } catch (e) {
      print('Error picking image from camera: $e');
    }
  }

  Future<void> pickImageFromGallery({required bool isAnalysisImage}) async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false);

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (isAnalysisImage) {
          state = state.copyWith(analysisImage: () => file);
        } else {
          state = state.copyWith(recipePhoto: () => file);
        }
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
  }

  void clearAnalysisImage() {
    state = state.copyWith(analysisImage: () => null);
  }

  void clearRecipePhoto() {
    state = state.copyWith(recipePhoto: () => null);
  }

  void clearAll() {
    state = const CustomImages();
  }
}
