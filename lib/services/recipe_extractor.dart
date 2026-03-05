import 'package:flutter/foundation.dart';
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
    if (lines.isEmpty) return ExtractionResult();
    return ExtractionResult(ingredientSections: processRawLines(lines));
  }

  /// Entry point for unit tests: skips OCR and starts directly from raw lines.
  static List<IngredientSection> processRawLines(List<String> lines) {
    List<String> split = splitOnDelimiters(lines);
    split = split.map(normalizeLineSpacing).toList();
    split = splitInlineIngredients(split);
    List<String> ingredients = mergeHyphenatedLines(split);
    ingredients = pairOrphanAmountsWithNames(ingredients);
    ingredients = mergeContinuationLines(ingredients);
    return _parseIngredients(createSections(ingredients));
  }

  static ExtractionResult extractRecipeInstructions(
      RecognizedText recognizedText) {
    final lines = _prepareRecognizedText(recognizedText);

    if (lines.isEmpty) {
      return ExtractionResult();
    }

    final instructions = assembleNumberedStepsFromString(lines.join("\n"));
    return ExtractionResult(instructions: instructions);
  }

  /* ===================== INSTRUCTIONS ===================== */

  @visibleForTesting
  static String assembleNumberedStepsFromString(String text) {
    // Merge words hyphenated across line breaks: "klein-\nschneiden" → "kleinschneiden"
    final merged = text.replaceAll(RegExp(r'-\s*\n\s*'), '');
    final lines = merged
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return assembleNumberedSteps(lines);
  }

  @visibleForTesting
  static String assembleNumberedSteps(List<String> lines) {
    // Matches "1. Text", "1: Text", "1) Text", "1- Text"
    final stepPattern = RegExp(r'^\s*(\d+)\s*[:\.\)\-]\s*(.+)$');
    // Fix 1: matches step number alone on a line, e.g. "1." or "2:"
    final stepNumberOnlyPattern = RegExp(r'^\s*(\d+)\s*[:\.\)\-]\s*$');
    final Map<int, StringBuffer> steps = {};
    int? currentStep;

    for (final line in lines) {
      // Fix 1: step number alone on a line → register step, wait for content
      final numberOnlyMatch = stepNumberOnlyPattern.firstMatch(line);
      if (numberOnlyMatch != null) {
        final step = int.parse(numberOnlyMatch.group(1)!);
        steps.putIfAbsent(step, () => StringBuffer());
        currentStep = step;
        continue;
      }

      final match = stepPattern.firstMatch(line);

      if (match != null) {
        final step = int.parse(match.group(1)!);
        final text = match.group(2)!.trim();

        // Fix 3: if the text after the number starts with a known unit,
        // it's a quantity ("2. EL Butter"), not a step → treat as continuation
        final firstWord = text.split(' ').first;
        if (UnitParser.parse(firstWord) != null) {
          if (currentStep != null) {
            steps[currentStep]!
              ..write(' ')
              ..write(line.trim());
          }
          continue;
        }

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

    // Fix 2: no numbered steps found → join with newlines to preserve structure
    if (steps.isEmpty) {
      return lines.join('\n');
    }

    final sortedKeys = steps.keys.toList()..sort();

    return sortedKeys
        .map((k) => '$k. ${steps[k]!.toString().trim()}')
        .join('\n\n');
  }

  /* ===================== INGREDIENTS ===================== */

  static final _delimiterPattern = RegExp(r'\s*[♦◆•·✦]\s*');

  static final _unitPatternString =
      UnitParser.patterns.map(RegExp.escape).join('|');

  // Fix 1: "abc)7" → "abc) 7"   Fix 2: "40g" → "40 g"
  @visibleForTesting
  static String normalizeLineSpacing(String line) {
    // Space between ) and digit
    line = line.replaceAllMapped(
      RegExp(r'\)(\d)'),
      (m) => ') ${m.group(1)}',
    );
    // Space between digit and unit when missing, e.g. "40g" → "40 g"
    line = line.replaceAllMapped(
      RegExp(r'(\d+(?:[,\.]\d+)?)(' + _unitPatternString + r')\b',
          caseSensitive: false),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
    return line;
  }

  @visibleForTesting
  static List<String> splitOnDelimiters(List<String> lines) {
    final List<String> output = [];
    for (final line in lines) {
      if (_delimiterPattern.hasMatch(line)) {
        final parts = line
            .split(_delimiterPattern)
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty);
        output.addAll(parts);
      } else {
        output.add(line);
      }
    }
    return output;
  }

  // Splits at: whitespace before "number + known unit" or "number + uppercase word"
  // Skips matches inside parentheses, e.g. "(ca. 10 g)"
  static final _unitInlineSplitPattern = RegExp(
    r'\s+(?=\d+(?:[,\.]\d+)?\s+(?:' +
        UnitParser.patterns.map(RegExp.escape).join('|') +
        r')\b)',
    caseSensitive: false,
  );
  static final _capitalInlineSplitPattern = RegExp(
    r'\s+(?=\d+(?:[,\.]\d+)?\s+[A-ZÄÖÜ])',
  );
  // Splits before inline section keywords (reuses _sectionPatterns)
  static final _inlineSectionPattern = RegExp(
    r'\s+(?=(?:' + _sectionPatterns.map(RegExp.escape).join('|') + r'))',
    caseSensitive: false,
  );

  @visibleForTesting
  static List<String> splitInlineIngredients(List<String> lines) {
    final List<String> output = [];
    for (final line in lines) {
      output.addAll(_splitLineOnIngredients(line));
    }
    return output;
  }

  static List<String> _splitLineOnIngredients(String line) {
    final positions = <int>{};

    // Section keywords: no parenthesis check needed, always split
    for (final m in _inlineSectionPattern.allMatches(line)) {
      positions.add(m.end);
    }

    // Ingredient-start patterns: skip matches inside parentheses
    for (final pattern in [
      _unitInlineSplitPattern,
      _capitalInlineSplitPattern
    ]) {
      for (final m in pattern.allMatches(line)) {
        int depth = 0;
        for (int i = 0; i < m.start; i++) {
          if (line[i] == '(')
            depth++;
          else if (line[i] == ')') depth--;
        }
        if (depth == 0) positions.add(m.end);
      }
    }

    if (positions.isEmpty) return [line];

    final sorted = positions.toList()..sort();
    final parts = <String>[];
    int start = 0;
    for (final pos in sorted) {
      final part = line.substring(start, pos).trim();
      if (part.isNotEmpty) parts.add(part);
      start = pos;
    }
    final last = line.substring(start).trim();
    if (last.isNotEmpty) parts.add(last);
    return parts;
  }

  static const _sectionPatterns = [
    'für den ',
    'für die ',
    'für das ',
    'für ca.',
    'teig',
    'füllung',
    'sauce',
    'soße',
    'marinade',
    'dressing',
    'topping',
    'beilage',
    'garnitur',
    'glasur',
    'guss',
    'creme',
    'belag',
    'außerdem',
    'zusätzlich',
    'zum servieren',
    'boden',
    'streusel',
    'ganache',
    'baiser',
    'vinaigrette',
    'pesto',
    'chutney',
    'salsa',
    'zum garnieren',
    'zum dekorieren',
    'zum bestreuen',
    'zum bestäuben',
    'panade',
    'kruste',
    'brühe',
    'mousse',
  ];

  @visibleForTesting
  static bool isSectionHeader(String line) {
    // (a) Beginnt mit Großbuchstabe
    if (line[0] != line[0].toUpperCase() || line[0] == line[0].toLowerCase()) {
      return false;
    }

    // (b) Enthält keine Zahl → Zeilen mit Mengenangaben sind Zutaten
    if (RegExp(r'\d').hasMatch(line)) {
      return false;
    }

    // (c) Endet mit ":" oder matcht bekanntes Header-Pattern
    if (line.endsWith(':') || line.endsWith('::')) {
      return true;
    }

    final lowerLine = line.toLowerCase();
    return _sectionPatterns.any((p) => lowerLine.contains(p));
  }

  @visibleForTesting
  static Map<String, List<String>> createSections(List<String> lines) {
    Map<String, List<String>> output = {};
    String currentSection = "Zutaten";

    for (String line in lines) {
      if (isSectionHeader(line)) {
        // "Außerdem: Backpapier" → header="Außerdem", item="Backpapier"
        final colonIdx = line.indexOf(':');
        final String header;
        final String? inlineItem;
        if (colonIdx > 0 && colonIdx < line.length - 1) {
          header = line.substring(0, colonIdx).trim();
          final rest = line.substring(colonIdx + 1).trim();
          inlineItem = rest.isNotEmpty ? rest : null;
        } else {
          header = line.endsWith(':')
              ? line.substring(0, line.length - 1).trim()
              : line;
          inlineItem = null;
        }
        output[header] = [];
        currentSection = header;
        if (inlineItem != null) output[header]!.add(inlineItem);
      } else {
        if (output.isEmpty || !output.containsKey(currentSection)) {
          output[currentSection] = [];
        }
        output[currentSection]!.add(line);
      }
    }

    return output;
  }

  @visibleForTesting
  static List<String> mergeContinuationLines(List<String> list) {
    List<String> output = [];

    for (int i = list.length - 1; i >= 0; i--) {
      String line = list[i];
      if (i > 0 &&
          line[0] == line[0].toLowerCase() &&
          line[0] != line[0].toUpperCase() &&
          !_quantitylessIngredients
              .any((z) => line.toLowerCase().contains(z))) {
        output.insert(0, list[i - 1] + " " + line);
        i--;
      } else if (i > 0 &&
          _flourType.any((z) => line.toLowerCase().contains(z))) {
        output.insert(0, list[i - 1] + " " + line);
        i--;
      } else if (i > 0 && line.startsWith('(')) {
        output.insert(0, list[i - 1] + " " + line);
        i--;
      } else {
        output.insert(0, line);
      }
    }

    return output;
  }

  // Ingredients that are never measured — skip pairing even if an orphan is queued
  static const _neverPairedIngredients = [
    'salz',
    'pfeffer',
    'muskat',
    'muskatnuss'
  ];

  static final _orphanAmountPattern = RegExp(
    r'^\d+(?:[,\.]\d+)?\s*(?:' + _unitPatternString + r')?\s*$',
    caseSensitive: false,
  );

  /// Pairs "orphan" amount-only lines (e.g. "3 EL") with the next name-only line
  /// (e.g. "Rapsöl") that follows in the sequence — as produced by column
  /// clustering when a tabular recipe layout is scanned.
  @visibleForTesting
  static List<String> pairOrphanAmountsWithNames(List<String> lines) {
    final queue = <String>[];
    final output = <String>[];
    final deferred = <_Deferred>[];
    int pairingsDone = 0;

    for (final line in lines) {
      final startsWithDigit = line.isNotEmpty && RegExp(r'^\d').hasMatch(line);
      final isFlourContinuation =
          _flourType.any((z) => line.toLowerCase().startsWith(z));
      final neverPaired =
          _neverPairedIngredients.any((z) => line.toLowerCase().contains(z));

      if (_orphanAmountPattern.hasMatch(line)) {
        // Only number + optional unit, no ingredient name → queue
        queue.add(line);
      } else if (line.startsWith('(') || isFlourContinuation) {
        // Parenthetical continuation or flour type → append to previous
        if (output.isNotEmpty) {
          output[output.length - 1] += ' $line';
        } else {
          output.add(line);
        }
      } else if (startsWithDigit && !neverPaired) {
        // Complete line appearing while orphans are queued → defer it until
        // all queue entries that existed before it have been paired off.
        if (queue.isEmpty) {
          output.add(line);
        } else {
          deferred.add(_Deferred(pairingsDone + queue.length, line));
        }
      } else if (neverPaired || queue.isEmpty) {
        // Truly quantityless or nothing queued → pass through immediately
        output.add(line);
        _flushDeferred(deferred, pairingsDone, output);
      } else {
        // Name-only line with a queued orphan amount → pair them
        output.add('${queue.removeAt(0)} $line');
        pairingsDone++;
        _flushDeferred(deferred, pairingsDone, output);
      }
    }

    // Flush any remaining deferred and unmatched orphans
    deferred.sort((a, b) => a.remaining.compareTo(b.remaining));
    output.addAll(deferred.map((d) => d.line));
    output.addAll(queue);
    return output;
  }

  static void _flushDeferred(
      List<_Deferred> deferred, int pairingsDone, List<String> output) {
    // Output deferred items whose required pairing count has been reached.
    deferred.removeWhere((d) {
      if (pairingsDone >= d.remaining) {
        output.add(d.line);
        return true;
      }
      return false;
    });
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

  @visibleForTesting
  static List<String> mergeHyphenatedLines(List<String> lines) {
    List<String> output = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      int lastIndex = line.length - 1;
      if (line.endsWith('-') && i + 1 < lines.length) {
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
    final lineText = normalizeIngredientText(ingredientLine);
    final tokens = lineText.split(' ');
    String? amount = parseAmountToken(tokens.first);
    Unit? unit;
    String name = '';

    if (amount != null && tokens.length > 1) {
      unit = UnitParser.parse(tokens[1]);
      if (unit == null) {
        unit = Unit.PIECE;
        name = tokens.skip(1).join(" ");
      } else {
        name = tokens.skip(2).join(" ");
      }
    } else if (amount != null) {
      unit = Unit.PIECE;
      name = amount;
      amount = null;
    } else if (tokens.length > 1 && UnitParser.parse(tokens[1]) != null) {
      unit = UnitParser.parse(tokens[1]);
      amount = tokens.first;
      name = tokens.skip(2).join(" ");
    } else {
      name = tokens.join(" ");
    }

    return Ingredient(name: name, unit: unit, amount: amount);
  }

  /// Validiert und übernimmt Mengen als TEXT (keine Berechnung!)
  @visibleForTesting
  static String? parseAmountToken(String token) {
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

  @visibleForTesting
  static String normalizeIngredientText(String text) {
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

    return lines.map((l) => l.text.trim()).where((t) => t.isNotEmpty).toList();
  }
}

/* ===================== INTERNAL ===================== */

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

class _Deferred {
  final int remaining;
  final String line;
  _Deferred(this.remaining, this.line);
}
