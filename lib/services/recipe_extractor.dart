import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';

class ExtractionResult {
  final List<IngredientSection>? ingredientSections;
  final String? instructions;

  ExtractionResult({this.ingredientSections, this.instructions});
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

    List<String> ingredients = _mergeHyphenatedLines(lines);
    ingredients = _mergeContinuationLines(ingredients);

    Map<String, List<String>> ingredientSectionsMap =
        _createSections(ingredients);

    List<IngredientSection> ingredientSections =
        _parseIngredients(ingredientSectionsMap);

    print("????????????????????? printing sections ?????????????????");
    for (IngredientSection section in ingredientSections) {
      print("============= sectionTitle: ${section.title} ============= ");
      for (Ingredient ing in section.ingredients) {
        print("${ing.amount} ${ing.unit?.displayName}: ${ing.name}");
      }
    }

    return ExtractionResult(ingredientSections: ingredientSections);
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

  static Map<String, List<String>> _createSections(List<String> lines) {
    Map<String, List<String>> output = {};
    String currentSection = "Zutaten";

    for (String line in lines) {
      if (line[0] == line[0].toUpperCase() &&
          line[0] != line[0].toLowerCase() &&
          !_quantitylessIngredients
              .any((z) => line.toLowerCase().contains(z))) {
        output[line] = [];
        currentSection = line;
      } else {
        if (output.isEmpty || !output.containsKey(currentSection)) {
          output[currentSection] = [];
        }
        output[currentSection]!.add(line);
      }
    }

    return output;
  }

  static List<String> _mergeContinuationLines(List<String> list) {
    List<String> output = [];

    for (int i = list.length - 1; i >= 0; i--) {
      String line = list[i];
      if (line[0] == line[0].toLowerCase() &&
          line[0] != line[0].toUpperCase() &&
          !_quantitylessIngredients
              .any((z) => line.toLowerCase().contains(z))) {
        output.insert(0, list[i - 1] + " " + line);
        i--;
      } else if (_flourType.any((z) => line.toLowerCase().contains(z))) {
        output.insert(0, list[i - 1] + " " + line);
        i--;
      } else {
        output.insert(0, line);
      }
    }

    return output;
  }

  static const _flourType = [
    'type',
    'typ',
  ];

  static const _quantitylessIngredients = [
    'salz',
    'pfeffer',
    'muskat',
    'muskatnuss',
    'zimt',
    'paprikapulver',
    'curry',
    'kreuzkümmel',
    'kumin',
    'oregano',
    'basilikum',
    'thymian',
    'rosmarin',
    'petersilie',
    'schnittlauch',
    'dill',
    'koriander',
    'majoran',
    'chiliflocken',
    'cayennepfeffer',
    'zucker',
  ];

  static List<String> _mergeHyphenatedLines(List<String> lines) {
    List<String> output = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      int lastIndex = line.length - 1;
      if (line.endsWith('-')) {
        String nextLine = lines[i + 1].trim();
        if (nextLine[0] == nextLine[0].toLowerCase()) {
          String lineAdd = line.substring(0, lastIndex);
          output.add(lineAdd + nextLine);
        } else {
          output.add(line + nextLine);
        }
        i++;
      } else {
        output.add(line);
      }
    }

    return output;
  }

  static const _stopWords = ['alternativ', 'oder', 'evtl'];
  static const _minNameLength = 2;

  static List<IngredientSection> _parseIngredients(
      Map<String, List<String>> ingredientSectionsMap) {
    List<IngredientSection> output = [];

    for (String sectionName in ingredientSectionsMap.keys) {
      IngredientSection currentSection =
          IngredientSection(title: sectionName, ingredients: []);
      for (String ingredientLine in ingredientSectionsMap[sectionName]!) {
        currentSection.ingredients.add(_parseIngredientLine(ingredientLine));
      }
      output.add(currentSection);
    }
    return output;
  }

  static Ingredient _parseIngredientLine(String ingredientLine) {
    final lineText = _normalizeIngredientText(ingredientLine);
    final tokens = lineText.split(' ');
    String? amount = _parseAmountToken(tokens.first);
    Unit? unit;
    String name = '';

    if (amount != null) {
      unit = UnitParser.parse(tokens[1]);
      if (unit == null) {
        unit = Unit.PIECE;
        name = tokens.skip(1).join(" ");
      } else {
        name = tokens.skip(2).join(" ");
      }
    } else if (tokens.length > 1 && UnitParser.parse(tokens[1]) != null) {
      unit = UnitParser.parse(tokens[1]);
      amount = tokens.first;
      name = tokens.skip(2).join(" ");
    } else {
      name = tokens.join(" ");
    }

    return Ingredient(name: name, unit: unit, amount: amount);
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
    text = text.replaceAll('½', '1/2');
    text = text.replaceAll('¼', '1/4');
    text = text.replaceAll('¾', '3/4');
    text = text.replaceAll('⅓', '1/3');
    text = text.replaceAll('⅔', '2/3');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    final unitPatterns = UnitParser.patterns.join('|');

    text = text.replaceAllMapped(
      RegExp(
        r'(\d+(?:[,\.]\d+)?)(' + unitPatterns + r')\b',
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

    // collect all lines
    for (final block in recognizedText.blocks) {
      lines.addAll(block.lines);
    }

    // return early
    if (lines.isEmpty) {
      return [];
    }

    // sort lines by left
    lines.sort((a, b) {
      return a.boundingBox.left.compareTo(b.boundingBox.left);
    });

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

    // add column back to a list
    lines = columns.expand((column) => column).toList();

    // print lines for debugging
    for (TextLine textLine in lines) {
      print(textLine.text);
    }

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
