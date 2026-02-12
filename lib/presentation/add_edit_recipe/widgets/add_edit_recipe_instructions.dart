import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_analysis_provider.dart';

class AddEditRecipeInstructions extends ConsumerStatefulWidget {
  final TextEditingController recipeInstructionsController;
  const AddEditRecipeInstructions({
    super.key,
    required this.recipeInstructionsController,
  });
  @override
  ConsumerState<AddEditRecipeInstructions> createState() =>
      _AddRecipeInstructions();
}

class _AddRecipeInstructions extends ConsumerState<AddEditRecipeInstructions> {
  @override
  Widget build(BuildContext context) {
    ref.listen(recipeAnalysisProvider, (previous, next) {
      final data = next.data;
      if (data != null && data.instructions != null && data != previous?.data) {
        widget.recipeInstructionsController.text += data.instructions!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Anleitung erfolgreich analysiert!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    ref.listen(imageManagerProvider, (previous, next) {
      final image = next.instructionsImage;
      if (image != null && image != previous?.instructionsImage) {
        ref.read(recipeAnalysisProvider.notifier).analyzeImage(
              image: image,
              isIngredientImage: false,
            );
      }
    });

    final analysisState = ref.watch(recipeAnalysisProvider);
    final isAnalyzing =
        analysisState.isLoading && analysisState.isLoadingInstructions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Anleitung",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Gap(10),
            IconButton(
              onPressed: () {
                ref.read(imageManagerProvider.notifier).pickImageFromCamera(
                    imageType: AnalysisImageType.instructions);
              },
              icon: Icon(Icons.camera_alt_outlined),
            ),
            Gap(10),
            IconButton(
              onPressed: () {
                ref.read(imageManagerProvider.notifier).pickImageFromGallery(
                    imageType: AnalysisImageType.instructions);
              },
              icon: Icon(Icons.folder_outlined),
            ),
          ],
        ),
        SizedBox(height: 10),
        LoadingOverlay(
          isLoading: isAnalyzing,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey, width: 1.5),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: TextFormField(
              controller: widget.recipeInstructionsController,
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
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
        ),
      ],
    );
  }
}
