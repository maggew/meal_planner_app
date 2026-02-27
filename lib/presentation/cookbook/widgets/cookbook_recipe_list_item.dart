import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/plan_recipe_sheet.dart';
import 'package:meal_planner/presentation/common/glass_card.dart';

class CookbookRecipeListItem extends StatelessWidget {
  final Recipe recipe;
  const CookbookRecipeListItem({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset('assets/images/Rosi.png', fit: BoxFit.cover);
    final recipeImage = (recipe.imageUrl == null ||
            recipe.imageUrl!.isEmpty ||
            recipe.imageUrl == 'assets/images/default_pic_2.jpg')
        ? fallback
        : Image.network(
            recipe.imageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            },
            errorBuilder: (_, __, ___) => fallback,
          );

    return GestureDetector(
      onTap: () {
        context.router.root
            .push(ShowRecipeRoute(recipe: recipe, image: recipeImage));
      },
      onLongPress: recipe.id == null
          ? null
          : () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => PlanRecipeSheet(
                  recipeId: recipe.id!,
                  recipeName: recipe.name,
                ),
              ),
      child: Container(
        height: 100,
        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 10),
              Hero(
                tag: recipe.name,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 80,
                    child: recipeImage,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  recipe.name,
                  maxLines: 4,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

