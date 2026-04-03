import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/utils/recipe_link_parser.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

/// A Text widget that renders `@[Name](id)` links as clickable recipe references.
/// Falls back to a plain [Text] widget when no links are present.
class RecipeLinkText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const RecipeLinkText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    if (!RecipeLinkParser.hasLinks(text)) {
      return Text(text, style: style);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final linkStyle = style?.copyWith(
      color: colorScheme.primary,
      decoration: TextDecoration.underline,
    );

    final segments = RecipeLinkParser.parse(text);
    return Text.rich(
      TextSpan(
        children: segments.map<InlineSpan>((segment) {
          return switch (segment) {
            PlainText(:final text) => TextSpan(text: text, style: style),
            LinkedRecipe(:final link) => TextSpan(
                text: link.displayName,
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    context.router.root
                        .push(ShowRecipeRoute(recipeId: link.recipeId));
                  },
              ),
          };
        }).toList(),
      ),
    );
  }
}
