import 'package:meal_planner/core/utils/german_text_normalizer.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/carb_tag.dart';

class CarbTagDetector {
  static const _keywords = <CarbTag, List<String>>{
    CarbTag.reis: ['reis', 'rice', 'risotto', 'reismehl'],
    CarbTag.pasta: ['pasta', 'nudel', 'spaghetti', 'penne', 'fusilli', 'tagliatelle', 'linguine', 'farfalle', 'rigatoni', 'lasagne', 'gnocchi', 'tortellini', 'noodle'],
    CarbTag.kartoffel: ['kartoffel', 'potato', 'pommes', 'knoedel', 'kloesse', 'pueree', 'puree', 'bratkartoffel', 'suesskartoffel'],
    CarbTag.brot: ['brot', 'bread', 'toast', 'broetchen', 'baguette', 'ciabatta', 'pita', 'wrap', 'tortilla', 'focaccia', 'semmel'],
    CarbTag.couscousBulgur: ['couscous', 'bulgur', 'quinoa', 'hirse', 'freekeh', 'griess'],
  };

  // Compound words that contain a carb keyword but are NOT carbohydrate sources
  // (condiments, oils, vinegars). Checked before keyword matching.
  static const _falsePositives = <CarbTag, List<String>>{
    CarbTag.reis: ['reisweinessig', 'reisessig', 'reisoel'],
  };

  static bool _isFalsePositive(CarbTag tag, String normalizedName) {
    return (_falsePositives[tag] ?? const [])
        .any((fp) => normalizedName.contains(fp));
  }

  static List<CarbTag> detect(List<IngredientSection> sections) {
    final allIngredientNames = sections
        .expand((s) => s.ingredients)
        .map((i) => i.name)
        .toList();

    final found = <CarbTag>{};

    for (final entry in _keywords.entries) {
      for (final keyword in entry.value) {
        for (final name in allIngredientNames) {
          final normalized = GermanTextNormalizer.normalizeSimple(name);
          if (_isFalsePositive(entry.key, normalized)) continue;
          if (normalized.contains(keyword)) {
            found.add(entry.key);
            break;
          }
        }
        if (found.contains(entry.key)) break;
      }
    }

    if (found.isEmpty) return [CarbTag.keine];
    return found.toList();
  }

  /// Detect from a flat list of ingredient name strings (for recipe name / search)
  static List<CarbTag> detectFromNames(List<String> names) {
    final found = <CarbTag>{};
    for (final entry in _keywords.entries) {
      for (final keyword in entry.value) {
        for (final name in names) {
          final normalized = GermanTextNormalizer.normalizeSimple(name);
          if (_isFalsePositive(entry.key, normalized)) continue;
          if (normalized.contains(keyword)) {
            found.add(entry.key);
            break;
          }
        }
        if (found.contains(entry.key)) break;
      }
    }
    if (found.isEmpty) return [CarbTag.keine];
    return found.toList();
  }
}
