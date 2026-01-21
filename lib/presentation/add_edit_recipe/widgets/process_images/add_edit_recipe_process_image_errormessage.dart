import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/recipe/recipe_analysis_provider.dart';

class AddEditRecipeProcessImageErrormessage extends ConsumerWidget {
  final File image;
  final bool isIngredientImage;
  const AddEditRecipeProcessImageErrormessage({
    super.key,
    required this.image,
    required this.isIngredientImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(recipeAnalysisProvider);
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Fehler bei Analyse: ${analysisState.error}',
              style: TextStyle(color: Colors.red.shade900),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(recipeAnalysisProvider.notifier).analyzeImage(
                  image: image, isIngredientImage: isIngredientImage);
            },
            child: Text('Erneut'),
          ),
        ],
      ),
    );
  }
}
