import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/model/scraped_recipe_data.dart';
import 'package:meal_planner/data/services/recipe_scraper_service.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/recipe_url_import_sheet.dart';
import 'package:meal_planner/services/providers/recipe/recipe_scraper_provider.dart';

// --- Fake Notifiers ---

class _ErrorScraper extends RecipeScraper {
  @override
  AsyncValue<ScrapedRecipeData?> build() => const AsyncData(null);

  @override
  Future<ScrapedRecipeData?> scrape(String url) async {
    state = AsyncError(
      RecipeScrapingException('Diese Seite wird nicht unterstützt'),
      StackTrace.empty,
    );
    return null;
  }
}

/// First call → error, second call → hangs forever.
/// Used to verify the error is cleared as soon as a retry starts.
class _ErrorThenHangScraper extends RecipeScraper {
  int _calls = 0;
  final Completer<ScrapedRecipeData?> _completer = Completer();

  @override
  AsyncValue<ScrapedRecipeData?> build() => const AsyncData(null);

  @override
  Future<ScrapedRecipeData?> scrape(String url) async {
    _calls++;
    if (_calls == 1) {
      state = AsyncError(
        RecipeScrapingException('Diese Seite wird nicht unterstützt'),
        StackTrace.empty,
      );
      return null;
    }
    state = const AsyncLoading();
    return _completer.future;
  }
}

// --- Helper ---

Widget _buildSheet({
  required RecipeScraper Function() scraperFactory,
  void Function(ScrapedRecipeData)? onImported,
}) {
  return ProviderScope(
    overrides: [
      recipeScraperProvider.overrideWith(scraperFactory),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: RecipeUrlImportSheet(onImported: onImported ?? (_) {}),
      ),
    ),
  );
}

// --- Tests ---

void main() {
  group('RecipeUrlImportSheet Fehleranzeige', () {
    testWidgets('kein Fehler-Widget sichtbar im Ausgangszustand', (tester) async {
      await tester.pumpWidget(
        _buildSheet(scraperFactory: _ErrorScraper.new),
      );
      await tester.pump();

      expect(find.text('Diese Seite wird nicht unterstützt'), findsNothing);
    });

    testWidgets(
        'zeigt Fehlermeldung direkt im Sheet – nicht als SnackBar hinter dem Sheet',
        (tester) async {
      await tester.pumpWidget(
        _buildSheet(scraperFactory: _ErrorScraper.new),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'https://example.com');
      await tester.tap(find.text('Importieren'));
      await tester.pump();

      // Error text must appear in the sheet body (not hidden in a SnackBar)
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Diese Seite wird nicht unterstützt'), findsOneWidget);
    });

    testWidgets(
        'Fehlermeldung verschwindet sofort wenn ein neuer Import gestartet wird',
        (tester) async {
      await tester.pumpWidget(
        _buildSheet(scraperFactory: _ErrorThenHangScraper.new),
      );
      await tester.pump();

      // First import → error
      await tester.enterText(find.byType(TextField), 'https://example.com');
      await tester.tap(find.text('Importieren'));
      await tester.pump();

      expect(find.text('Diese Seite wird nicht unterstützt'), findsOneWidget);

      // Second import → hangs; error must vanish before any new result arrives
      await tester.tap(find.text('Importieren'));
      await tester.pump();

      expect(find.text('Diese Seite wird nicht unterstützt'), findsNothing);
    });
  });
}
