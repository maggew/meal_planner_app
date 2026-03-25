import 'package:meal_planner/data/model/scraped_recipe_data.dart';
import 'package:meal_planner/data/services/recipe_scraper_service.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_scraper_provider.g.dart';

@riverpod
class RecipeScraper extends _$RecipeScraper {
  @override
  AsyncValue<ScrapedRecipeData?> build() => const AsyncData(null);

  Future<ScrapedRecipeData?> scrape(String url) async {
    state = const AsyncLoading();
    try {
      final service = RecipeScraperService(ref.read(scrapingDioProvider));
      final data = await service.scrape(url);
      state = AsyncData(data);
      return data;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}
