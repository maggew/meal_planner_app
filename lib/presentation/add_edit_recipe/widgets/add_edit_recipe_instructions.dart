import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    ref.listen(recipeAnalysisProvider, (previous, next) {
      final data = next.data;
      if (data != null && data.instructions != null && data != previous?.data) {
        widget.recipeInstructionsController.text += data.instructions!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Anleitung erfolgreich analysiert!'),
            backgroundColor: colorScheme.primary,
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
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10,
          children: [
            Text(
              "Anleitung",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            IconButton(
              onPressed: () {
                ref.read(imageManagerProvider.notifier).pickImageFromCamera(
                    imageType: AnalysisImageType.instructions);
              },
              icon: Icon(Icons.camera_alt_outlined),
            ),
            IconButton(
              onPressed: () {
                ref.read(imageManagerProvider.notifier).pickImageFromGallery(
                    imageType: AnalysisImageType.instructions);
              },
              icon: Icon(Icons.folder_outlined),
            ),
          ],
        ),
        LoadingOverlay(
          isLoading: isAnalyzing,
          child: TextFormField(
            controller: widget.recipeInstructionsController,
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surfaceContainer,
              enabledBorder: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusAll,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusAll,
                borderSide: BorderSide(color: colorScheme.primary, width: 2.5),
              ),
              hintText: 'Hier ist Platz für die Kochanweisungen...',
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
        ),
      ],
    );
  }
}
