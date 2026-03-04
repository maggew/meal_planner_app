import 'package:meal_planner/core/utils/german_text_normalizer.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/carb_tag.dart';

class CarbTagDetector {
  static const _keywords = <CarbTag, List<String>>{
    CarbTag.reis: ['reis', 'rice', 'risotto', 'reismehl'],
    CarbTag.pasta: ['pasta', 'nudel', 'spaghetti', 'penne', 'fusilli', 'tagliatelle', 'linguine', 'farfalle', 'rigatoni', 'lasagne', 'gnocchi', 'tortellini', 'noodle'],
    CarbTag.kartoffel: ['kartoffel', 'potato', 'pommes', 'knödel', 'kloesse', 'püree', 'puree', 'bratkartoffel', 'süsskartoffel', 'suesskartoffel'],
    CarbTag.brot: ['brot', 'bread', 'toast', 'brötchen', 'broetchen', 'baguette', 'ciabatta', 'pita', 'wrap', 'tortilla', 'focaccia', 'semmel'],
    CarbTag.couscousBulgur: ['couscous', 'bulgur', 'quinoa', 'hirse', 'freekeh', 'grieß', 'griess'],
  };

  static List<CarbTag> detect(List<IngredientSection> sections) {
    final allIngredientNames = sections
        .expand((s) => s.ingredients)
        .map((i) => i.name)
        .toList();

    final found = <CarbTag>{};

    for (final entry in _keywords.entries) {
      for (final keyword in entry.value) {
        for (final name in allIngredientNames) {
          if (GermanTextNormalizer.normalizeSimple(name).contains(keyword)) {
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
          if (GermanTextNormalizer.normalizeSimple(name).contains(keyword)) {
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
