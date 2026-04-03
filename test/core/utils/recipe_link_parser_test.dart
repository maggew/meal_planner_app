import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/utils/recipe_link_parser.dart';

void main() {
  group('RecipeLinkParser', () {
    group('encode', () {
      test('escapes parentheses in recipe name', () {
        final result =
            RecipeLinkParser.encode('Pasta (vegan)', 'recipe-123');
        expect(result, r'@[Pasta \(vegan\)](recipe-123)');
      });

      test('escapes brackets in recipe name', () {
        final result =
            RecipeLinkParser.encode('Omas Soße [original]', 'recipe-456');
        expect(result, r'@[Omas Soße \[original\]](recipe-456)');
      });

      test('leaves plain names unchanged', () {
        final result = RecipeLinkParser.encode('Burger', 'id-1');
        expect(result, '@[Burger](id-1)');
      });
    });

    group('parse', () {
      test('roundtrip: encode then parse with special characters', () {
        final encoded =
            RecipeLinkParser.encode('Pasta (vegan)', 'recipe-123');
        final text = 'Bereite $encoded zu';
        final segments = RecipeLinkParser.parse(text);

        expect(segments.length, 3);
        expect(segments[0], isA<PlainText>());
        expect((segments[0] as PlainText).text, 'Bereite ');
        expect(segments[1], isA<LinkedRecipe>());
        final link = (segments[1] as LinkedRecipe).link;
        expect(link.displayName, 'Pasta (vegan)');
        expect(link.recipeId, 'recipe-123');
        expect(segments[2], isA<PlainText>());
        expect((segments[2] as PlainText).text, ' zu');
      });

      test('roundtrip with brackets in name', () {
        final encoded =
            RecipeLinkParser.encode('Omas Soße [original]', 'recipe-456');
        final segments = RecipeLinkParser.parse(encoded);

        expect(segments.length, 1);
        final link = (segments[0] as LinkedRecipe).link;
        expect(link.displayName, 'Omas Soße [original]');
        expect(link.recipeId, 'recipe-456');
      });
    });

    group('extractFirst', () {
      test('extracts link with special characters', () {
        final encoded =
            RecipeLinkParser.encode('Pasta (vegan)', 'recipe-123');
        final link = RecipeLinkParser.extractFirst('Dazu: $encoded');

        expect(link, isNotNull);
        expect(link!.displayName, 'Pasta (vegan)');
        expect(link.recipeId, 'recipe-123');
      });
    });

    group('stripLinks', () {
      test('strips syntax but keeps unescaped display name', () {
        final encoded =
            RecipeLinkParser.encode('Pasta (vegan)', 'recipe-123');
        final result = RecipeLinkParser.stripLinks('Dazu: $encoded');
        expect(result, 'Dazu: Pasta (vegan)');
      });
    });

    group('hasLinks', () {
      test('detects link with escaped characters', () {
        final encoded =
            RecipeLinkParser.encode('Pasta (vegan)', 'recipe-123');
        expect(RecipeLinkParser.hasLinks(encoded), isTrue);
      });

      test('returns false for plain text', () {
        expect(RecipeLinkParser.hasLinks('Pasta (vegan)'), isFalse);
      });
    });
  });
}
