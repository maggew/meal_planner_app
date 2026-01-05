import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';

class RecipeExtractor {
  static Map<String, dynamic> extractRecipeData(RecognizedText recognizedText) {
    // Text spaltenweise sortiert
    String completeText = _getCompleteTextColumnWise(recognizedText);

    // Zeilen aufteilen
    List<String> lines = completeText
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return {
        'name': null,
        'ingredients': [],
        'instructions': null,
        'fullText': completeText,
      };
    }

    // Erster Block als Name (bis zur ersten leeren Zeile oder Mengenangabe)
    String? name;
    int nameEndIndex = 0;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      // Stoppe bei erster Mengenangabe
      if (line
          .contains(RegExp(r'\d+\s*(g|ml|kg|l|EL|TL)', caseSensitive: false))) {
        nameEndIndex = i;
        break;
      }

      // Stoppe bei Schritt-Nummer
      if (line.startsWith(RegExp(r'^\d+\.'))) {
        nameEndIndex = i;
        break;
      }

      // Sammle Zeilen für den Namen (maximal 3 Zeilen)
      if (i < 3) {
        if (name == null) {
          name = line;
        } else {
          name += ' ' + line;
        }
      }
    }

    // Zutaten sammeln (von nameEndIndex bis "1.")
    List<String> ingredients = [];
    int instructionsStartIndex = lines.length;

    for (int i = nameEndIndex; i < lines.length; i++) {
      String line = lines[i].trim();

      // Sobald "1." kommt, beginnen die Anweisungen
      if (line.startsWith(RegExp(r'^\d+\.'))) {
        instructionsStartIndex = i;
        break;
      }

      // Zeile zu Zutaten hinzufügen
      if (line.isNotEmpty) {
        ingredients.add(line);
      }
    }

    // Anweisungen sammeln (ab "1.")
    List<String> steps = [];
    StringBuffer currentStep = StringBuffer();

    for (int i = instructionsStartIndex; i < lines.length; i++) {
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

    return {
      'name': name,
      'ingredients': _getIngredients(ingredients),
      'instructions': steps.toString(),
      'fullText': completeText,
    };
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

  static List<Ingredient> _getIngredients(List<String> ingredients) {
    List<Ingredient> out = [];

    String text = _normalizeIngredientText(ingredients.join(' '));

    List<String> tokens = text.split(' ');

    int i = 0;
    while (i < tokens.length) {
      String token = tokens[i];

      double? amount = double.tryParse(token.replaceAll(',', '.'));

      if (amount != null && i + 1 < tokens.length) {
        i++;

        Unit? unit = UnitParser.parse(tokens[i]); // ← Diese Zeile ändern

        if (unit != null) {
          i++; // Überspringe Einheit
        }

        // Sammle den Namen
        StringBuffer name = StringBuffer();

        while (i < tokens.length) {
          String word = tokens[i];

          if (double.tryParse(word.replaceAll(',', '.')) != null) {
            break;
          }

          if (word.toLowerCase().contains('alternativ')) {
            break;
          }

          name.write(word);
          name.write(' ');
          i++;
        }

        String ingredientName = name.toString().trim();

        ingredientName =
            ingredientName.replaceAll(RegExp(r'[,\.\(\)]+$'), '').trim();

        if (ingredientName.isNotEmpty && ingredientName.length >= 2) {
          out.add(Ingredient(
            amount: amount,
            unit: unit ?? Unit.GRAMM,
            name: ingredientName,
          ));
        }
      } else {
        i++;
      }
    }

    return out;
  }

  static String _getCompleteTextColumnWise(RecognizedText recognizedText) {
    List<TextLine> allLines = [];

    for (var block in recognizedText.blocks) {
      allLines.addAll(block.lines);
    }

    if (allLines.isEmpty) return '';

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

    return result.toString();
  }
}
