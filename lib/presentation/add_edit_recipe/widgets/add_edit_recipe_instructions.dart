import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_analysis_provider.dart';

// Wird vom Section-Delete-Flow gesetzt, um einen Tastatur-Flash zu verhindern.
// Wenn true, kann das Instructions-TextField keinen Fokus erhalten.
final excludeInstructionsFocusNotifier = ValueNotifier<bool>(false);

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
  late final FocusNode _focusNode;

  void _onExcludeChanged() {
    _focusNode.canRequestFocus = !excludeInstructionsFocusNotifier.value;
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    excludeInstructionsFocusNotifier.addListener(_onExcludeChanged);
  }

  @override
  void dispose() {
    excludeInstructionsFocusNotifier.removeListener(_onExcludeChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    ref.listen(recipeAnalysisProvider, (previous, next) {
      final data = next.data;
      if (data != null && data.instructions != null && data != previous?.data) {
        widget.recipeInstructionsController.text += data.instructions!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anleitung erfolgreich analysiert'),
            backgroundColor: colorScheme.primary,
          ),
        );
      }
      if (next.error != null &&
          next.error != previous?.error &&
          !next.isLoadingIngredients) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analyse fehlgeschlagen')),
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
              style: Theme.of(context).textTheme.titleLarge,
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
            Tooltip(
              message:
                  "📷 Kamera: Anleitung direkt scannen\n🗂 Galerie: Bild aus Galerie auswählen",
              triggerMode: TooltipTriggerMode.tap,
              showDuration: Duration(seconds: 4),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.help_outline, size: 20),
              ),
            ),
          ],
        ),
        LoadingOverlay(
          isLoading: isAnalyzing,
          child: TextFormField(
            focusNode: _focusNode,
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
