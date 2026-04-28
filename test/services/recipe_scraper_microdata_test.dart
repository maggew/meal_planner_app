import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/services/recipe_scraper_service.dart';

void main() {
  late RecipeScraperService service;

  setUp(() {
    service = RecipeScraperService(Dio());
  });

  group('Microdata recipe extraction (Schema.org itemProp attributes)', () {
    test('extracts grouped ingredients with sub-section headers', () {
      // Mirrors zuckerjagdwurst.com: no JSON-LD, itemProp on li elements,
      // h4 sub-headings before each ingredient group inside a shared div.
      const html = '''
<html>
<head>
  <meta property="og:title" content="Spitzkohl-Rösti - Zuckerjagdwurst" />
  <meta property="og:site_name" content="Zuckerjagdwurst" />
  <meta property="og:image" content="https://example.com/roesti.jpg" />
</head>
<body>
<main>
  <div itemProp="recipeYield">2 Portionen / 4 Rösti</div>
  <div class="ingredients-wrapper">
    <div class="text-renderer">
      <h4>Für die Rösti:</h4>
      <ul>
        <li itemProp="recipeIngredient">400 g Spitzkohl</li>
        <li itemProp="recipeIngredient">100 g Karotten</li>
        <li itemProp="recipeIngredient">150 g Weizenmehl</li>
      </ul>
      <h4>Für die Sour-Cream:</h4>
      <ul>
        <li itemProp="recipeIngredient">300 g vegane Sour-Cream</li>
        <li itemProp="recipeIngredient">1 TL Zitrone</li>
      </ul>
    </div>
  </div>
  <div itemProp="recipeInstructions">
    <ol>
      <li>Spitzkohl hobeln und Karotten raspeln.</li>
      <li>Teig in die heiße Pfanne geben und braten.</li>
    </ol>
  </div>
</main>
</body>
</html>
''';

      final result = service.tryExtractMicrodataRecipe(html);

      expect(result, isNotNull);
      expect(result!.name, 'Spitzkohl-Rösti');
      expect(result.ingredients, [
        'Für die Rösti:',
        '400 g Spitzkohl',
        '100 g Karotten',
        '150 g Weizenmehl',
        'Für die Sour-Cream:',
        '300 g vegane Sour-Cream',
        '1 TL Zitrone',
      ]);
      expect(result.instructions, contains('1.'));
      expect(result.instructions, contains('2.'));
      expect(result.servings, 2);
      expect(result.imageUrl, 'https://example.com/roesti.jpg');
    });

    test('extracts flat ingredient list without sub-sections', () {
      const html = '''
<html>
<head>
  <meta property="og:title" content="Einfaches Rezept" />
</head>
<body>
<main>
  <ul>
    <li itemProp="recipeIngredient">200 g Mehl</li>
    <li itemProp="recipeIngredient">2 Eier</li>
    <li itemProp="recipeIngredient">100 ml Milch</li>
  </ul>
</main>
</body>
</html>
''';

      final result = service.tryExtractMicrodataRecipe(html);

      expect(result, isNotNull);
      expect(result!.ingredients, [
        '200 g Mehl',
        '2 Eier',
        '100 ml Milch',
      ]);
    });

    test('returns null when no itemProp=recipeIngredient elements present', () {
      const html = '''
<html>
<head><meta property="og:title" content="Some Page" /></head>
<body><ul><li>Regular list item</li></ul></body>
</html>
''';

      final result = service.tryExtractMicrodataRecipe(html);
      expect(result, isNull);
    });

    test('returns null when fewer than 2 ingredients found', () {
      const html = '''
<html>
<head><meta property="og:title" content="Some Page" /></head>
<body>
  <li itemProp="recipeIngredient">Only one ingredient</li>
</body>
</html>
''';

      final result = service.tryExtractMicrodataRecipe(html);
      expect(result, isNull);
    });

    test('returns null when og:title is missing', () {
      const html = '''
<html>
<body>
  <ul>
    <li itemProp="recipeIngredient">200 g Mehl</li>
    <li itemProp="recipeIngredient">2 Eier</li>
  </ul>
</body>
</html>
''';

      final result = service.tryExtractMicrodataRecipe(html);
      expect(result, isNull);
    });

    test('strips site-name suffix from og:title', () {
      const html = '''
<html>
<head>
  <meta property="og:title" content="Veganer Auflauf - Meine Seite" />
  <meta property="og:site_name" content="Meine Seite" />
</head>
<body>
  <ul>
    <li itemProp="recipeIngredient">200 g Nudeln</li>
    <li itemProp="recipeIngredient">100 g Käse</li>
  </ul>
</body>
</html>
''';

      final result = service.tryExtractMicrodataRecipe(html);

      expect(result, isNotNull);
      expect(result!.name, 'Veganer Auflauf');
    });

    test('extracts servings from recipeYield with mixed text', () {
      const html = '''
<html>
<head><meta property="og:title" content="Test Rezept" /></head>
<body>
  <div itemProp="recipeYield">4 Portionen / 8 Stücke</div>
  <ul>
    <li itemProp="recipeIngredient">Zutat 1</li>
    <li itemProp="recipeIngredient">Zutat 2</li>
  </ul>
</body>
</html>
''';

      final result = service.tryExtractMicrodataRecipe(html);
      expect(result!.servings, 4);
    });
  });
}
