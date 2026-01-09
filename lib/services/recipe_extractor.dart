import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';

class ExtractionResult {
  final List<Ingredient>? ingredients;
  final String? instructions;

  ExtractionResult({this.ingredients, this.instructions});
}

class RecipeExtractor {
  RecipeExtractor._();

  static ExtractionResult extractRecipeIngredients(
      RecognizedText recognizedText) {
    // Text spaltenweise sortiert
    List<String> lines = _prepareRecognizedText(recognizedText);

    // Zeilen aufteilen

    if (lines.isEmpty) {
      return ExtractionResult();
    }

    return ExtractionResult(ingredients: _getIngredients(lines));
  }

  static ExtractionResult extractRecipeInstructions(
      RecognizedText recognizedText) {
    // Text spaltenweise sortiert
    List<String> lines = _prepareRecognizedText(recognizedText);

    if (lines.isEmpty) {
      return ExtractionResult();
    }
    List<String> steps = [];
    StringBuffer currentStep = StringBuffer();

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      // Neue Schritt-Nummer gefunden
      if (line.startsWith(RegExp(r'^\d+\.'))) {
        // Vorherigen Schritt speichern
        if (currentStep.isNotEmpty) {
          steps.add(currentStep.toString().trim());
          currentStep.clear();
        }

        // Neuen Schritt beginnen
        currentStep.write(line);
      } else if (currentStep.isNotEmpty) {
        // Fortsetzung des aktuellen Schritts
        currentStep.write(' ');
        currentStep.write(line);
      }
    }

    // Letzten Schritt speichern
    if (currentStep.isNotEmpty) {
      steps.add(currentStep.toString().trim());
    }

    return ExtractionResult(instructions: steps.join("\n\n"));
  }

  static String _normalizeIngredientText(String text) {
    // Bereinige Sonderzeichen
    text = text.replaceAll('•', ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Füge Leerzeichen zwischen Zahl und Einheit ein
    // Behandelt: 100g, 2EL, 1,5kg, 300ml, etc.
    text = text.replaceAllMapped(
      RegExp(
          r'(\d+(?:[,\.]\d+)?)(g|kg|ml|l|EL|TL|el|tl|Prise|prise|Stück|stück|Stk|stk)\b',
          caseSensitive: false),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    // Füge auch Leerzeichen zwischen Zahl und Buchstabe ein (falls keine Einheit)
    // z.B. "2Zwiebeln" -> "2 Zwiebeln"
    text = text.replaceAllMapped(
      RegExp(r'(\d+)([A-ZÄÖÜ])', caseSensitive: false),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return text;
  }

  static const _stopWords = ['alternativ', 'oder', 'evtl'];
  static const _minNameLength = 2;

  static List<Ingredient> _getIngredients(List<String> lines) {
    final text = _normalizeIngredientText(lines.join(' '));
    final tokens = text.split(' ');
    final ingredients = <Ingredient>[];

    int i = 0;
    while (i < tokens.length) {
      final parsed = _tryParseIngredient(tokens, i);

      if (parsed != null) {
        ingredients.add(parsed.ingredient);
        i = parsed.nextIndex;
      } else {
        i++;
      }
    }

    return ingredients;
  }

  static _ParseResult? _tryParseIngredient(
      List<String> tokens, int startIndex) {
    int i = startIndex;

    // 1. Amount parsen
    final amount = _parseAmount(tokens[i]);
    if (amount == null || i + 1 >= tokens.length) return null;
    i++;

    // 2. Unit parsen (optional)
    final unit = UnitParser.parse(tokens[i]);
    if (unit != null) i++;

    // 3. Name sammeln
    final name = _collectName(tokens, i);
    if (name.value.length < _minNameLength) return null;

    return _ParseResult(
      ingredient: Ingredient(
        amount: amount,
        unit: unit ?? Unit.GRAMM,
        name: name.value,
      ),
      nextIndex: name.endIndex,
    );
  }

  static double? _parseAmount(String token) {
    // Normale Zahlen
    final normal = double.tryParse(token.replaceAll(',', '.'));
    if (normal != null) return normal;

    // Brüche: 1/2, 1/4
    final fractionMatch = RegExp(r'^(\d+)/(\d+)$').firstMatch(token);
    if (fractionMatch != null) {
      final num = int.parse(fractionMatch.group(1)!);
      final den = int.parse(fractionMatch.group(2)!);
      return num / den;
    }

    return null;
  }

  static ({String value, int endIndex}) _collectName(
      List<String> tokens, int startIndex) {
    final buffer = StringBuffer();
    int i = startIndex;

    while (i < tokens.length) {
      final word = tokens[i];

      // Stop bei nächster Zahl
      if (_parseAmount(word) != null) break;

      // Stop bei Stop-Wörtern
      if (_stopWords.any((sw) => word.toLowerCase().contains(sw))) break;

      buffer.write(word);
      buffer.write(' ');
      i++;
    }

    final name =
        buffer.toString().trim().replaceAll(RegExp(r'[,\.\(\)]+$'), '');
    return (value: name, endIndex: i);
  }

  static List<String> _prepareRecognizedText(RecognizedText recognizedText) {
    List<TextLine> allLines = [];

    for (var block in recognizedText.blocks) {
      allLines.addAll(block.lines);
    }

    if (allLines.isEmpty) return [];

    // Finde Bildmitte
    double maxRight = 0;
    for (var line in allLines) {
      if (line.boundingBox.right > maxRight) {
        maxRight = line.boundingBox.right;
      }
    }

    double middle = maxRight / 2;

    // Teile in Spalten
    List<TextLine> leftColumn = [];
    List<TextLine> rightColumn = [];

    for (var line in allLines) {
      double centerX = line.boundingBox.left + (line.boundingBox.width / 2);

      if (centerX < middle) {
        leftColumn.add(line);
      } else {
        rightColumn.add(line);
      }
    }

    // Sortiere beide Spalten nach Y (von OBEN nach UNTEN)
    // Falls falsch herum, tausche a und b
    leftColumn.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));
    rightColumn.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    // Kombiniere
    StringBuffer result = StringBuffer();

    for (var line in leftColumn) {
      result.writeln(line.text);
    }

    result.writeln();

    for (var line in rightColumn) {
      result.writeln(line.text);
    }

    return result
        .toString()
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
  }
}

class _ParseResult {
  final Ingredient ingredient;
  final int nextIndex;

  _ParseResult({required this.ingredient, required this.nextIndex});
}
