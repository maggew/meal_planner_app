import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_analysis_provider.dart';

class AddRecipeProcessImage extends ConsumerWidget {
  final File image;
  const AddRecipeProcessImage({super.key, required this.image});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(recipeAnalysisProvider);
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bild
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Overlay während Analyse
          if (analysisState.isLoading)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Rezept wird analysiert...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // X-Button zum Entfernen (nur wenn nicht am laden)
          if (!analysisState.isLoading)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
                onPressed: () {
                  ref.read(imageManagerProvider.notifier).clearAnalysisImage();
                },
              ),
            ),
        ],
      ),
    );
  }
}
