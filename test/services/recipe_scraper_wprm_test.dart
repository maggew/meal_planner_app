import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:meal_planner/data/services/recipe_scraper_service.dart';
import 'package:meal_planner/services/recipe_extractor.dart';

void main() {
  late RecipeScraperService service;

  setUp(() {
    service = RecipeScraperService(Dio());
  });

  group('WPRM ingredient extraction', () {
    test('extracts grouped ingredients with section headers', () {
      final html = '''
<div class="wprm-recipe-ingredient-group">
  <div class="wprm-recipe-group-name">Süß-Sauer-Soße</div>
  <ul class="wprm-recipe-ingredients">
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">120</span>
      <span class="wprm-recipe-ingredient-unit">ml</span>
      <span class="wprm-recipe-ingredient-name">Wasser</span>
    </li>
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">2</span>
      <span class="wprm-recipe-ingredient-unit">TL</span>
      <span class="wprm-recipe-ingredient-name">Maisstärke</span>
    </li>
  </ul>
</div>
<div class="wprm-recipe-ingredient-group">
  <div class="wprm-recipe-group-name">Knuspriger Tofu</div>
  <ul class="wprm-recipe-ingredients">
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">300</span>
      <span class="wprm-recipe-ingredient-unit">g</span>
      <span class="wprm-recipe-ingredient-name">Tofu</span>
      <span class="wprm-recipe-ingredient-notes">gewürfelt</span>
    </li>
  </ul>
</div>
''';

      final result = service.tryExtractWprmIngredients(html);

      expect(result, isNotNull);
      expect(result, [
        'Süß-Sauer-Soße:',
        '120 ml Wasser',
        '2 TL Maisstärke',
        'Knuspriger Tofu:',
        '300 g Tofu gewürfelt',
      ]);
    });

    test('returns null when no WPRM structure found', () {
      final html = '<html><body><p>Just a normal page</p></body></html>';

      final result = service.tryExtractWprmIngredients(html);

      expect(result, isNull);
    });

    test('handles group without header name', () {
      final html = '''
<div class="wprm-recipe-ingredient-group">
  <ul class="wprm-recipe-ingredients">
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">1</span>
      <span class="wprm-recipe-ingredient-unit">EL</span>
      <span class="wprm-recipe-ingredient-name">Öl</span>
    </li>
  </ul>
</div>
''';

      final result = service.tryExtractWprmIngredients(html);

      expect(result, ['1 EL Öl']);
    });

    test('handles ingredient without amount or unit', () {
      final html = '''
<div class="wprm-recipe-ingredient-group">
  <div class="wprm-recipe-group-name">Toppings</div>
  <ul class="wprm-recipe-ingredients">
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-name">Sesam</span>
    </li>
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-name">Frühlingszwiebeln</span>
    </li>
  </ul>
</div>
''';

      final result = service.tryExtractWprmIngredients(html);

      expect(result, [
        'Toppings:',
        'Sesam',
        'Frühlingszwiebeln',
      ]);
    });

    test('handles single group without header (no section line emitted)', () {
      final html = '''
<div class="wprm-recipe-ingredient-group">
  <ul class="wprm-recipe-ingredients">
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">500</span>
      <span class="wprm-recipe-ingredient-unit">g</span>
      <span class="wprm-recipe-ingredient-name">Mehl</span>
    </li>
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">1</span>
      <span class="wprm-recipe-ingredient-unit">TL</span>
      <span class="wprm-recipe-ingredient-name">Salz</span>
    </li>
  </ul>
</div>
''';

      final result = service.tryExtractWprmIngredients(html);

      expect(result, [
        '500 g Mehl',
        '1 TL Salz',
      ]);
    });

    test('sections feed correctly into RecipeExtractor', () {
      // Verify that WPRM output with "Header:" lines is recognized
      // as section headers by the existing RecipeExtractor pipeline
      final html = '''
<div class="wprm-recipe-ingredient-group">
  <div class="wprm-recipe-group-name">Soße</div>
  <ul class="wprm-recipe-ingredients">
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">2</span>
      <span class="wprm-recipe-ingredient-unit">EL</span>
      <span class="wprm-recipe-ingredient-name">Sojasauce</span>
    </li>
  </ul>
</div>
<div class="wprm-recipe-ingredient-group">
  <div class="wprm-recipe-group-name">Reis</div>
  <ul class="wprm-recipe-ingredients">
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">200</span>
      <span class="wprm-recipe-ingredient-unit">g</span>
      <span class="wprm-recipe-ingredient-name">Basmatireis</span>
    </li>
  </ul>
</div>
''';

      final wprmLines = service.tryExtractWprmIngredients(html)!;
      final sections =
          RecipeExtractor.processRawLines(wprmLines);

      expect(sections, hasLength(2));
      expect(sections[0].title, 'Soße');
      expect(sections[0].ingredients, hasLength(1));
      expect(sections[0].ingredients[0].name, 'Sojasauce');
      expect(sections[1].title, 'Reis');
      expect(sections[1].ingredients, hasLength(1));
      expect(sections[1].ingredients[0].name, 'Basmatireis');
    });
  });

  group('Tasty Recipes ingredient extraction', () {
    test('extracts grouped ingredients with h4 section headers', () {
      final html = '''
<div class="tasty-recipes-ingredients">
  <div class="tasty-recipes-ingredients-body">
    <h4>For the Cake</h4>
    <ul>
      <li data-tr-ingredient-checkbox>2 cups all purpose flour</li>
      <li data-tr-ingredient-checkbox>1 cup sugar</li>
    </ul>
    <h4>For the Frosting</h4>
    <ul>
      <li data-tr-ingredient-checkbox>1 cup cocoa powder</li>
      <li data-tr-ingredient-checkbox>4 cups powdered sugar</li>
    </ul>
  </div>
</div>
''';

      final result = service.tryExtractTastyRecipesIngredients(html);

      expect(result, [
        'For the Cake:',
        '2 cups all purpose flour',
        '1 cup sugar',
        'For the Frosting:',
        '1 cup cocoa powder',
        '4 cups powdered sugar',
      ]);
    });

    test('returns null when no Tasty Recipes structure found', () {
      final html = '<html><body><p>Just a normal page</p></body></html>';

      final result = service.tryExtractTastyRecipesIngredients(html);

      expect(result, isNull);
    });

    test('handles flat list without section headers', () {
      final html = '''
<div class="tasty-recipes-ingredients">
  <div class="tasty-recipes-ingredients-body">
    <ul>
      <li>200 g Mehl</li>
      <li>100 g Butter</li>
    </ul>
  </div>
</div>
''';

      final result = service.tryExtractTastyRecipesIngredients(html);

      expect(result, [
        '200 g Mehl',
        '100 g Butter',
      ]);
    });

    test('handles h3 headings as section headers', () {
      final html = '''
<div class="tasty-recipes-ingredients-body">
  <h3>Marinade</h3>
  <ul>
    <li>3 EL Sojasauce</li>
  </ul>
  <h3>Gemüse</h3>
  <ul>
    <li>1 Paprika</li>
  </ul>
</div>
''';

      final result = service.tryExtractTastyRecipesIngredients(html);

      expect(result, [
        'Marinade:',
        '3 EL Sojasauce',
        'Gemüse:',
        '1 Paprika',
      ]);
    });

    test('falls back to outer container when body div is absent', () {
      final html = '''
<div class="tasty-recipes-ingredients">
  <ul>
    <li>1 TL Salz</li>
    <li>2 EL Öl</li>
  </ul>
</div>
''';

      final result = service.tryExtractTastyRecipesIngredients(html);

      expect(result, [
        '1 TL Salz',
        '2 EL Öl',
      ]);
    });

    test('handles ordered list (ol)', () {
      final html = '''
<div class="tasty-recipes-ingredients-body">
  <h4>Dressing</h4>
  <ol>
    <li>2 EL Olivenöl</li>
    <li>1 EL Zitronensaft</li>
  </ol>
</div>
''';

      final result = service.tryExtractTastyRecipesIngredients(html);

      expect(result, [
        'Dressing:',
        '2 EL Olivenöl',
        '1 EL Zitronensaft',
      ]);
    });

    test('sections feed correctly into RecipeExtractor', () {
      final html = '''
<div class="tasty-recipes-ingredients-body">
  <h4>For the Cake</h4>
  <ul>
    <li>500 g Mehl</li>
    <li>1 TL Salz</li>
  </ul>
  <h4>For the Frosting</h4>
  <ul>
    <li>200 g Frischkäse</li>
  </ul>
</div>
''';

      final tastyLines = service.tryExtractTastyRecipesIngredients(html)!;
      final sections = RecipeExtractor.processRawLines(tastyLines);

      expect(sections, hasLength(2));
      expect(sections[0].title, 'For the Cake');
      expect(sections[0].ingredients, hasLength(2));
      expect(sections[0].ingredients[0].name, 'Mehl');
      expect(sections[1].title, 'For the Frosting');
      expect(sections[1].ingredients, hasLength(1));
      expect(sections[1].ingredients[0].name, 'Frischkäse');
    });
  });
}
