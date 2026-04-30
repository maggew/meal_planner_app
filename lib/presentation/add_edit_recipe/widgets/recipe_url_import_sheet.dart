import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/data/model/scraped_recipe_data.dart';
import 'package:meal_planner/services/providers/recipe/recipe_scraper_provider.dart';

void showRecipeUrlImportSheet(
  BuildContext context,
  void Function(ScrapedRecipeData) onImported,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => RecipeUrlImportSheet(onImported: onImported),
  );
}

class RecipeUrlImportSheet extends ConsumerStatefulWidget {
  final void Function(ScrapedRecipeData) onImported;

  const RecipeUrlImportSheet({super.key, required this.onImported});

  @override
  ConsumerState<RecipeUrlImportSheet> createState() =>
      _RecipeUrlImportSheetState();
}

class _RecipeUrlImportSheetState extends ConsumerState<RecipeUrlImportSheet> {
  late final TextEditingController _urlController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _onImportPressed() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    setState(() => _errorMessage = null);
    final data = await ref.read(recipeScraperProvider.notifier).scrape(url);
    if (!mounted) return;
    if (data != null) {
      Navigator.pop(context);
      widget.onImported(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scraperState = ref.watch(recipeScraperProvider);

    ref.listen(recipeScraperProvider, (prev, next) {
      if (next is AsyncError && next != prev) {
        final error = next.error;
        setState(() {
          _errorMessage =
              error is Exception ? error.toString() : 'Import fehlgeschlagen';
        });
      }
    });

    final isLoading = scraperState is AsyncLoading;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Rezept von URL importieren',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            enabled: !isLoading,
            keyboardType: TextInputType.url,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Rezept-URL',
              hintText: 'https://www.chefkoch.de/rezepte/...',
              prefixIcon: Icon(Icons.link),
            ),
            onSubmitted: (_) => _onImportPressed(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: isLoading ? null : _onImportPressed,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(isLoading ? 'Importiere...' : 'Importieren'),
          ),
        ],
      ),
    );
  }
}
