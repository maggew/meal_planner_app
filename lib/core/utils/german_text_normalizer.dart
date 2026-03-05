class GermanTextNormalizer {
  /// Nur Lowercase + Umlaute — kein Suffix-Stripping.
  /// Verwenden wenn Keywords gegen Ingredient-Namen geprüft werden.
  static String normalizeSimple(String input) {
    return input
        .toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss');
  }

  static String normalize(String input) {
    var s = input.toLowerCase();
    s = s
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss');

    // Strip common German suffixes (min 3 chars remaining)
    for (final suffix in [
      'ungen',
      'ung',
      'sten',
      'sten',
      'en',
      'er',
      'es',
      'e',
      'n',
      's',
    ]) {
      if (s.length - suffix.length >= 3 && s.endsWith(suffix)) {
        s = s.substring(0, s.length - suffix.length);
        break;
      }
    }
    return s;
  }

  static bool fuzzyMatch(String needle, String haystack) {
    final normalizedNeedle = normalize(needle);
    final normalizedHaystack = normalize(haystack);
    return normalizedHaystack.contains(normalizedNeedle);
  }
}
