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

  /* ===================== PUBLIC API ===================== */

  static ExtractionResult extractRecipeIngredients(
      RecognizedText recognizedText) {
    final lines = _prepareRecognizedText(recognizedText);

    if (lines.isEmpty) {
      return ExtractionResult();
    }

    return ExtractionResult(ingredients: _getIngredients(lines));
  }

  static ExtractionResult extractRecipeInstructions(
      RecognizedText recognizedText) {
    print("============== extracting instructions ===============");
    print("with the recgonizedText:");
    print(recognizedText.text);
    final lines = _prepareRecognizedText(recognizedText);

    if (lines.isEmpty) {
      return ExtractionResult();
    }

    String instructions = lines.join("\n").replaceAll(RegExp(r'-\s*\n\s*'), '');
    instructions = _assembleNumberedStepsFromString(instructions);
    return ExtractionResult(instructions: instructions);
  }

  /* ===================== INSTRUCTIONS ===================== */

  static String _assembleNumberedStepsFromString(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return _assembleNumberedSteps(lines);
  }

  static String _assembleNumberedSteps(List<String> lines) {
    final stepPattern = RegExp(r'^\s*(\d+)\s*[:\.\)\-]\s*(.+)$');
    final Map<int, StringBuffer> steps = {};
    int? currentStep;

    for (final line in lines) {
      final match = stepPattern.firstMatch(line);

      if (match != null) {
        final step = int.parse(match.group(1)!);
        final text = match.group(2)!.trim();

        steps.putIfAbsent(step, () => StringBuffer());

        if (text.isNotEmpty) {
          if (steps[step]!.isNotEmpty) {
            steps[step]!.write(' ');
          }
          steps[step]!.write(text);
        }

        currentStep = step;
      } else if (currentStep != null) {
        steps[currentStep]!
          ..write(' ')
          ..write(line.trim());
      }
    }

    if (steps.isEmpty) {
      return lines.join(' ');
    }

    final sortedKeys = steps.keys.toList()..sort();

    return sortedKeys
        .map((k) => '$k. ${steps[k]!.toString().trim()}')
        .join('\n\n');
  }

  /* ===================== INGREDIENTS ===================== */

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

    final amount = _parseAmountToken(tokens[i]);
    if (amount == null || i + 1 >= tokens.length) return null;
    i++;

    final unit = UnitParser.parse(tokens[i]);
    if (unit != null) i++;

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

  /// Validiert und übernimmt Mengen als TEXT (keine Berechnung!)
  static String? _parseAmountToken(String token) {
    final normalized = token.replaceAll(',', '.');

    // Zahl: 150 | 1.5
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(normalized)) {
      return normalized;
    }

    // Bereich: 150-200 | 150–200
    if (RegExp(r'^\d+(\.\d+)?\s*[-–]\s*\d+(\.\d+)?$').hasMatch(normalized)) {
      return normalized.replaceAll(RegExp(r'\s+'), '');
    }

    // Bruch: 1/2
    if (RegExp(r'^\d+/\d+$').hasMatch(normalized)) {
      return normalized;
    }

    return null;
  }

  static ({String value, int endIndex}) _collectName(
      List<String> tokens, int startIndex) {
    final buffer = StringBuffer();
    int i = startIndex;

    while (i < tokens.length) {
      final word = tokens[i];

      // Stop bei nächster Mengenangabe
      if (_parseAmountToken(word) != null) break;

      // Stop bei Stopwörtern
      if (_stopWords.any((sw) => word.toLowerCase().contains(sw))) break;

      buffer.write(word);
      buffer.write(' ');
      i++;
    }

    final name =
        buffer.toString().trim().replaceAll(RegExp(r'[,\.\(\)]+$'), '');
    return (value: name, endIndex: i);
  }

  static String _normalizeIngredientText(String text) {
    text = text.replaceAll('•', ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    text = text.replaceAllMapped(
      RegExp(
        r'(\d+(?:[,\.]\d+)?)(g|kg|ml|l|EL|TL|el|tl|Prise|prise|Stück|stück|Stk|stk)\b',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    text = text.replaceAllMapped(
      RegExp(r'(\d+)([A-ZÄÖÜ])', caseSensitive: false),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return text;
  }

  /* ===================== OCR PREPARATION ===================== */

  static List<String> _prepareRecognizedText(RecognizedText recognizedText) {
    List<TextLine> lines = [];
    print("============= in prepare ============");

    // collect all lines
    for (final block in recognizedText.blocks) {
      lines.addAll(block.lines);
    }

    // return early
    if (lines.isEmpty) {
      print("returning beaucse lines.isEmpty!");
      return [];
    }

    // sort lines by left
    lines.sort((a, b) {
      return a.boundingBox.left.compareTo(b.boundingBox.left);
    });
    print("========================= lines after sort by left: ");
    for (TextLine textLine in lines) {
      print(textLine.text);
    }

    // define xClusterThreshold
    const double xClusterThreshold = 40.0;

    // cluster lines
    List<List<TextLine>> columns = [];
    int columnIndex = 0;
    double lastLeft = lines.first.boundingBox.left;
    for (TextLine textLine in lines) {
      if ((textLine.boundingBox.left - lastLeft).abs() > xClusterThreshold) {
        columnIndex++;
      }
      if (columns.length <= columnIndex) {
        columns.add(<TextLine>[]);
      }

      columns[columnIndex].add(textLine);
      lastLeft = textLine.boundingBox.left;
    }

    // sorting columns
    columns.sort((a, b) => columnX(a).compareTo(columnX(b)));

    const double yTolerance = 8.0;
    // sort top to bot inside columns
    for (final column in columns) {
      column.sort((a, b) {
        final dy = (a.boundingBox.top - b.boundingBox.top).abs();
        if (dy < yTolerance) {
          return a.boundingBox.left.compareTo(b.boundingBox.left);
        }
        return a.boundingBox.top.compareTo(b.boundingBox.top);
      });
    }
    print("========================= lines after sorting inside columns: ");
    for (TextLine textLine in lines) {
      print(textLine.text);
    }

    // add column back to a list
    lines = columns.expand((column) => column).toList();

    // print lines for debugging
    print("============== printing lines ==================");
    for (TextLine textLine in lines) {
      print(textLine.text);
    }
    print("============== printing lines end ==================");

    // const double yTolerance = 8.0;
    //
    // lines.sort((a, b) {
    //   final dy = (a.boundingBox.top - b.boundingBox.top).abs();
    //   if (dy < yTolerance) {
    //     return a.boundingBox.left.compareTo(b.boundingBox.left);
    //   }
    //   return a.boundingBox.top.compareTo(b.boundingBox.top);
    // });

    return lines.map((l) => l.text.trim()).where((t) => t.isNotEmpty).toList();
  }
}

/* ===================== INTERNAL ===================== */

class _ParseResult {
  final Ingredient ingredient;
  final int nextIndex;

  _ParseResult({required this.ingredient, required this.nextIndex});
}

double columnX(List<TextLine> column) {
  double sum = 0;
  double weight = 0;

  for (final line in column) {
    final w = line.boundingBox.width;
    sum += line.boundingBox.left * w;
    weight += w;
  }

  return sum / weight;
}
