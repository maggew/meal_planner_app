import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/services/recipe_scraper_service.dart';

void main() {
  late RecipeScraperService service;

  setUp(() {
    service = RecipeScraperService(Dio());
  });

  group('Heuristic recipe extraction (unstructured prose pages)', () {
    test('extracts complete recipe from simply-vegan-style HTML', () {
      // Mirrors the structure of simply-vegan.org: <article>, <h3> headings
      // for "Zutaten" and "Zubereitung", <p><strong> as section headers
      // between <ul> blocks, og:title with site-name suffix, og:image.
      const html = '''
<html>
<head>
  <meta property="og:title" content="Veganer Sauerbraten - Simply Vegan" />
  <meta property="og:site_name" content="Simply Vegan" />
  <meta property="og:image" content="https://example.com/sauerbraten.jpg" />
</head>
<body>
<article>
  <h3>Zutaten für 4 Portionen</h3>
  <ul>
    <li>1 kg veganer Seitan-Braten</li>
  </ul>
  <p><strong>Für die Marinade</strong></p>
  <ul>
    <li>2 Zwiebeln</li>
    <li>3/4 l Rotwein</li>
  </ul>
  <p><strong>Für die Sauce</strong></p>
  <ul>
    <li>1 EL Rapsöl</li>
    <li>5 EL Rosinen</li>
  </ul>
  <h3>Zubereitung (30 Minuten)</h3>
  <p>Für die Marinade die Zwiebeln schälen und hacken.</p>
  <p>Im Topf aufkochen lassen.</p>
  <h3>Weitere Rezepte</h3>
  <p>Andere tolle Rezepte hier.</p>
</article>
</body>
</html>
''';

      final result = service.tryExtractHeuristicRecipe(html);

      expect(result, isNotNull);
      expect(result!.name, 'Veganer Sauerbraten');
      expect(result.ingredients, [
        '1 kg veganer Seitan-Braten',
        'Für die Marinade:',
        '2 Zwiebeln',
        '3/4 l Rotwein',
        'Für die Sauce:',
        '1 EL Rapsöl',
        '5 EL Rosinen',
      ]);
      expect(result.instructions, isNotNull);
      expect(result.instructions, contains('Marinade die Zwiebeln'));
      expect(result.instructions, contains('Im Topf aufkochen'));
      // The "Weitere Rezepte" boundary stops the walk — instructions must
      // not contain anything from after that heading.
      expect(result.instructions, isNot(contains('Andere tolle Rezepte')));
      expect(result.servings, 4);
      expect(result.imageUrl, 'https://example.com/sauerbraten.jpg');
    });

    test('returns null when no recognizable headings are present', () {
      const html = '''
<html>
<head><meta property="og:title" content="Some Page" /></head>
<body>
<article>
  <h3>About this article</h3>
  <p>Just some text.</p>
  <h3>Conclusion</h3>
  <p>Some more text.</p>
</article>
</body>
</html>
''';

      expect(service.tryExtractHeuristicRecipe(html), isNull);
    });

    test('section header strict match: <p><strong> only, not mixed text',
        () {
      // First <p> is a pure-bold section header → should be picked up.
      // Second <p> has plain text "Tipp: " outside the <strong> → must
      // NOT be treated as a section header.
      const html = '''
<html>
<head><meta property="og:title" content="Test" /></head>
<body>
<article>
  <h3>Zutaten</h3>
  <p><strong>Erste Gruppe</strong></p>
  <ul>
    <li>100 g Mehl</li>
    <li>50 g Zucker</li>
  </ul>
  <p>Tipp: <strong>vorher abwiegen</strong></p>
  <ul>
    <li>200 ml Milch</li>
  </ul>
</article>
</body>
</html>
''';

      final result = service.tryExtractHeuristicRecipe(html);

      expect(result, isNotNull);
      expect(result!.ingredients, [
        'Erste Gruppe:',
        '100 g Mehl',
        '50 g Zucker',
        '200 ml Milch',
      ]);
      // The "Tipp:" paragraph must not appear as a section header.
      expect(
        result.ingredients,
        isNot(contains('Tipp: vorher abwiegen:')),
      );
    });

    test('servings regex: German "für X Portionen"', () {
      const html = '''
<html><head><meta property="og:title" content="Test" /></head><body>
<article>
  <h3>Zutaten für 4 Portionen</h3>
  <ul><li>200 g Mehl</li><li>100 g Zucker</li></ul>
</article></body></html>
''';

      expect(service.tryExtractHeuristicRecipe(html)?.servings, 4);
    });

    test('servings regex: English "for X servings"', () {
      const html = '''
<html><head><meta property="og:title" content="Test" /></head><body>
<article>
  <h3>Ingredients for 6 servings</h3>
  <ul><li>2 cups flour</li><li>1 cup sugar</li></ul>
</article></body></html>
''';

      expect(service.tryExtractHeuristicRecipe(html)?.servings, 6);
    });

    test('servings regex: English "Serves X"', () {
      const html = '''
<html><head><meta property="og:title" content="Test" /></head><body>
<article>
  <h3>Ingredients (Serves 2)</h3>
  <ul><li>2 cups flour</li><li>1 cup sugar</li></ul>
</article></body></html>
''';

      expect(service.tryExtractHeuristicRecipe(html)?.servings, 2);
    });

    test('og:title strips " - Sitename" suffix when og:site_name matches',
        () {
      const html = '''
<html>
<head>
  <meta property="og:title" content="My Recipe - Awesome Blog" />
  <meta property="og:site_name" content="Awesome Blog" />
</head>
<body><article>
  <h3>Zutaten</h3>
  <ul><li>1 Apfel</li><li>2 Birnen</li></ul>
</article></body></html>
''';

      expect(service.tryExtractHeuristicRecipe(html)?.name, 'My Recipe');
    });

    test('og:title strips " | Sitename" pipe variant', () {
      const html = '''
<html>
<head>
  <meta property="og:title" content="My Recipe | Awesome Blog" />
  <meta property="og:site_name" content="Awesome Blog" />
</head>
<body><article>
  <h3>Zutaten</h3>
  <ul><li>1 Apfel</li><li>2 Birnen</li></ul>
</article></body></html>
''';

      expect(service.tryExtractHeuristicRecipe(html)?.name, 'My Recipe');
    });

    test('og:title kept as-is when no separator or no site_name', () {
      const html = '''
<html>
<head><meta property="og:title" content="Just A Recipe" /></head>
<body><article>
  <h3>Zutaten</h3>
  <ul><li>1 Apfel</li><li>2 Birnen</li></ul>
</article></body></html>
''';

      expect(service.tryExtractHeuristicRecipe(html)?.name, 'Just A Recipe');
    });

    test('extracts og:image as imageUrl', () {
      const html = '''
<html>
<head>
  <meta property="og:title" content="Test" />
  <meta property="og:image" content="https://cdn.example.com/photo.jpg" />
</head>
<body><article>
  <h3>Zutaten</h3>
  <ul><li>1 Apfel</li><li>2 Birnen</li></ul>
</article></body></html>
''';

      expect(
        service.tryExtractHeuristicRecipe(html)?.imageUrl,
        'https://cdn.example.com/photo.jpg',
      );
    });

    test(
        'instructions optional: returns recipe with null instructions '
        'when no Zubereitung heading exists', () {
      const html = '''
<html><head><meta property="og:title" content="Test" /></head><body>
<article>
  <h3>Zutaten für 2 Personen</h3>
  <ul>
    <li>200 g Mehl</li>
    <li>100 g Zucker</li>
  </ul>
</article></body></html>
''';

      final result = service.tryExtractHeuristicRecipe(html);

      expect(result, isNotNull);
      expect(result!.ingredients, ['200 g Mehl', '100 g Zucker']);
      expect(result.instructions, isNull);
      expect(result.servings, 2);
    });

    test('rejects extraction when fewer than 2 ingredients found', () {
      const html = '''
<html><head><meta property="og:title" content="Test" /></head><body>
<article>
  <h3>Zutaten</h3>
  <ul><li>1 Apfel</li></ul>
  <h3>Zubereitung</h3>
  <p>Apfel essen.</p>
</article></body></html>
''';

      expect(service.tryExtractHeuristicRecipe(html), isNull);
    });

    test('instructions walk stops at next h3 (e.g. "Weitere Rezepte")', () {
      const html = '''
<html><head><meta property="og:title" content="Test" /></head><body>
<article>
  <h3>Zutaten</h3>
  <ul>
    <li>200 g Mehl</li>
    <li>100 g Zucker</li>
  </ul>
  <h3>Zubereitung</h3>
  <p>Schritt eins erledigen.</p>
  <p>Schritt zwei erledigen.</p>
  <h3>Weitere Rezepte</h3>
  <p>Vorschlag eins.</p>
  <p>Vorschlag zwei.</p>
</article></body></html>
''';

      final result = service.tryExtractHeuristicRecipe(html);

      expect(result, isNotNull);
      expect(result!.instructions, contains('Schritt eins'));
      expect(result.instructions, contains('Schritt zwei'));
      expect(result.instructions, isNot(contains('Vorschlag')));
    });

    test('falls back to <main> when no <article> exists', () {
      const html = '''
<html><head><meta property="og:title" content="Test" /></head><body>
<main>
  <h3>Zutaten</h3>
  <ul>
    <li>200 g Mehl</li>
    <li>100 g Zucker</li>
  </ul>
  <h3>Zubereitung</h3>
  <p>Vermischen und backen.</p>
</main></body></html>
''';

      final result = service.tryExtractHeuristicRecipe(html);

      expect(result, isNotNull);
      expect(result!.ingredients, ['200 g Mehl', '100 g Zucker']);
      expect(result.instructions, contains('Vermischen'));
    });
  });

  group('Pinterest guard', () {
    Future<void> expectBlocked(String url) async {
      await expectLater(
        () => service.scrape(url),
        throwsA(
          isA<RecipeScrapingException>().having(
            (e) => e.message,
            'message',
            contains('Pinterest'),
          ),
        ),
      );
    }

    test('blocks pinterest.com', () => expectBlocked('https://pinterest.com/pin/123/'));
    test('blocks pinterest.de', () => expectBlocked('https://pinterest.de/pin/123/'));
    test('blocks de.pinterest.com subdomain',
        () => expectBlocked('https://de.pinterest.com/pin/123/'));
    test('blocks www.pinterest.de subdomain',
        () => expectBlocked('https://www.pinterest.de/pin/123/'));
    test('blocks pin.it short links',
        () => expectBlocked('https://pin.it/abc123'));
  });

  group('HTTP request headers', () {
    test('uses browser-like User-Agent and Accept-Language', () async {
      Map<String, dynamic>? capturedHeaders;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedHeaders = Map<String, dynamic>.from(options.headers);
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'aborted by test',
              ),
            );
          },
        ),
      );
      final s = RecipeScraperService(dio);

      // The request will fail (interceptor rejects), so scrape() throws.
      // We only care about the headers it tried to send.
      await expectLater(
        () => s.scrape('https://example.com/recipe'),
        throwsA(isA<RecipeScrapingException>()),
      );

      expect(capturedHeaders, isNotNull);
      final ua = capturedHeaders!['User-Agent']?.toString() ?? '';
      expect(ua, contains('Mozilla'));
      expect(ua, contains('Chrome'));
      expect(ua, isNot(contains('RecipeBot')));

      final acceptLang =
          capturedHeaders!['Accept-Language']?.toString() ?? '';
      expect(acceptLang, contains('de'));
    });
  });
}
