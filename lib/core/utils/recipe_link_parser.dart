class RecipeLink {
  final String displayName;
  final String recipeId;

  const RecipeLink({required this.displayName, required this.recipeId});
}

sealed class RecipeLinkSegment {
  const RecipeLinkSegment();
}

class PlainText extends RecipeLinkSegment {
  final String text;
  const PlainText(this.text);
}

class LinkedRecipe extends RecipeLinkSegment {
  final RecipeLink link;
  const LinkedRecipe(this.link);
}

class RecipeLinkParser {
  static final _linkRegex =
      RegExp(r'@\[((?:[^\]\\]|\\.)+)\]\(((?:[^)\\]|\\.)+)\)');

  static String _unescape(String s) =>
      s.replaceAllMapped(RegExp(r'\\(.)'), (m) => m.group(1)!);

  /// Parses text containing `@[RecipeName](recipeId)` patterns into segments.
  static List<RecipeLinkSegment> parse(String text) {
    final segments = <RecipeLinkSegment>[];
    int lastEnd = 0;

    for (final match in _linkRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        segments.add(PlainText(text.substring(lastEnd, match.start)));
      }
      segments.add(LinkedRecipe(RecipeLink(
        displayName: _unescape(match.group(1)!),
        recipeId: _unescape(match.group(2)!),
      )));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      segments.add(PlainText(text.substring(lastEnd)));
    }

    return segments;
  }

  /// Encodes a recipe reference into the `@[name](id)` format.
  /// Escapes `[`, `]`, `(`, `)` in the recipe name.
  static String encode(String recipeName, String recipeId) {
    final escaped = recipeName
        .replaceAll(r'\', r'\\')
        .replaceAll('[', r'\[')
        .replaceAll(']', r'\]')
        .replaceAll('(', r'\(')
        .replaceAll(')', r'\)');
    return '@[$escaped]($recipeId)';
  }

  /// Extracts the first link from text, or null if none found.
  static RecipeLink? extractFirst(String text) {
    final match = _linkRegex.firstMatch(text);
    if (match == null) return null;
    return RecipeLink(
        displayName: _unescape(match.group(1)!),
        recipeId: _unescape(match.group(2)!));
  }

  /// Returns true if the text contains any recipe links.
  static bool hasLinks(String text) => _linkRegex.hasMatch(text);

  /// Strips link syntax, keeping only display names.
  static String stripLinks(String text) {
    return text.replaceAllMapped(_linkRegex, (m) => _unescape(m.group(1)!));
  }
}
